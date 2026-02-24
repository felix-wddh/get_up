import Foundation
@preconcurrency import CoreNFC
import CryptoKit

/// NFC scanning states
enum NFCScanState {
    case idle
    case scanning
    case success
    case failed
}

/// NFC scan mode
enum NFCScanMode {
    case bind      // Scanning to bind a tag to an alarm
    case verify    // Scanning to verify against a known tag hash
}

/// Service for managing NFC tag scanning sessions
@MainActor
final class NFCService: NSObject, ObservableObject {
    static let shared = NFCService()
    
    @Published var scanState: NFCScanState = .idle
    @Published var errorMessage: String?
    @Published var lastScannedTagId: String?
    @Published var lastScannedTagHash: String?
    
    var isScanning: Bool { scanState == .scanning }
    
    /// Check if NFC is available on this device
    static var isAvailable: Bool {
        NFCTagReaderSession.readingAvailable
    }
    
    private var session: NFCTagReaderSession?
    private var onComplete: ((Bool, String?, String?) -> Void)?  // success, tagId, tagHash
    private var scanMode: NFCScanMode = .bind
    private var expectedTagHash: String?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public API
    
    /// Start an NFC scanning session for binding a new tag
    func startBindingScan(completion: @escaping (Bool, String?, String?) -> Void) {
        scanMode = .bind
        expectedTagHash = nil
        startSession(
            message: "Hold your GetUp tag near the top of your iPhone",
            completion: completion
        )
    }
    
    /// Start an NFC scanning session to verify against a known tag
    func startVerificationScan(expectedHash: String, completion: @escaping (Bool, String?, String?) -> Void) {
        scanMode = .verify
        expectedTagHash = expectedHash
        startSession(
            message: "Scan your NFC tag to stop the alarm",
            completion: completion
        )
    }
    
    /// Stop the current scanning session
    func stopScanning() {
        session?.invalidate()
        session = nil
        scanState = .idle
        expectedTagHash = nil
    }
    
    /// Reset state
    func reset() {
        scanState = .idle
        errorMessage = nil
        lastScannedTagId = nil
        lastScannedTagHash = nil
        expectedTagHash = nil
    }
    
    #if DEBUG
    /// Simulate a successful NFC scan for testing
    func mockScan() {
        guard scanState == .scanning else { return }
        
        Task {
            // Simulate network/hardware delay
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            await MainActor.run {
                let mockId = "MOCK-TAG-123"
                let mockHash = self.generateTagHash(from: mockId)
                
                // If we're verifying and have an expected hash, use that instead to succeed
                let finalHash = self.expectedTagHash ?? mockHash
                
                self.processDetectedTag(tagId: mockId, tagHash: finalHash)
                print("🧪 Mock scan completed: \(mockId)")
            }
        }
    }
    #endif
    
    // MARK: - Private Methods
    
    private func startSession(message: String, completion: @escaping (Bool, String?, String?) -> Void) {
        guard NFCTagReaderSession.readingAvailable else {
            scanState = .failed
            errorMessage = "NFC is not available on this device"
            completion(false, nil, nil)
            return
        }
        
        onComplete = completion
        scanState = .scanning
        errorMessage = nil
        
        // Create NFC session on main thread, delegate runs on background
        session = NFCTagReaderSession(
            pollingOption: [.iso14443, .iso15693, .iso18092],
            delegate: self,
            queue: nil
        )
        session?.alertMessage = message
        session?.begin()
    }
    
    /// Generate a SHA256 hash of the tag identifier for privacy-preserving storage
    private nonisolated func generateTagHash(from identifier: String) -> String {
        let data = Data(identifier.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    /// Verify if a scanned tag matches the expected hash
    private nonisolated func verifyTag(scannedHash: String, expectedHash: String) -> Bool {
        // Constant-time comparison to prevent timing attacks
        guard scannedHash.count == expectedHash.count else { return false }
        
        var result: UInt8 = 0
        for (a, b) in zip(scannedHash.utf8, expectedHash.utf8) {
            result |= a ^ b
        }
        return result == 0
    }
}

// MARK: - NFCTagReaderSessionDelegate

extension NFCService: NFCTagReaderSessionDelegate {
    
    nonisolated func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("📡 NFC session became active")
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let nsError = error as NSError
        
        // User cancelled - not an error
        if nsError.code == NFCReaderError.readerSessionInvalidationErrorUserCanceled.rawValue {
            DispatchQueue.main.async {
                self.scanState = .idle
                self.onComplete?(false, nil, nil)
            }
            return
        }
        
        // First NDEF tag read - also normal
        if nsError.code == NFCReaderError.readerSessionInvalidationErrorFirstNDEFTagRead.rawValue {
            return
        }
        
        // Actual error
        print("❌ NFC session error: \(error.localizedDescription)")
        Task { @MainActor in
            self.scanState = .failed
            self.errorMessage = error.localizedDescription
            self.onComplete?(false, nil, nil)
        }
    }
    
    nonisolated func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag detected")
            return
        }
        
        // Connect to the tag
        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }
            
            // Extract tag identifier based on type
            let tagId = self.extractTagIdentifier(from: tag)
            let tagHash = self.generateTagHash(from: tagId)
            
            print("✅ NFC tag detected (hash prefix: \(tagHash.prefix(8)))")
            print("🔐 Tag hash: \(tagHash.prefix(16))...")
            
            // Handle based on mode on MainActor
            Task { @MainActor in
                self.processDetectedTag(tagId: tagId, tagHash: tagHash)
            }
        }
    }
    
    @MainActor
    private func processDetectedTag(tagId: String, tagHash: String) {
        switch self.scanMode {
        case .bind:
            // Binding mode - just return the hash
            session?.alertMessage = "Tag registered!"
            session?.invalidate()
            
            self.lastScannedTagId = tagId
            self.lastScannedTagHash = tagHash
            self.scanState = .success
            self.onComplete?(true, tagId, tagHash)
            
        case .verify:
            // Verification mode - compare against expected hash
            if let expected = self.expectedTagHash, self.verifyTag(scannedHash: tagHash, expectedHash: expected) {
                session?.alertMessage = "Tag verified! Alarm stopped."
                session?.invalidate()
                
                self.lastScannedTagId = tagId
                self.lastScannedTagHash = tagHash
                self.scanState = .success
                self.onComplete?(true, tagId, tagHash)
            } else {
                session?.alertMessage = "Wrong tag! Try your registered GetUp tag."
                // Keep session open for retry
                self.errorMessage = "Wrong tag - please scan the correct GetUp tag"
                self.scanState = .failed
                self.onComplete?(false, tagId, tagHash)
            }
        }
    }
    
    /// Extract a unique identifier from the NFC tag
    nonisolated private func extractTagIdentifier(from tag: NFCTag) -> String {
        switch tag {
        case .iso7816(let iso7816Tag):
            return iso7816Tag.identifier.hexString
            
        case .iso15693(let iso15693Tag):
            return iso15693Tag.identifier.hexString
            
        case .feliCa(let felicaTag):
            return felicaTag.currentIDm.hexString
            
        case .miFare(let mifareTag):
            return mifareTag.identifier.hexString
            
        @unknown default:
            return UUID().uuidString
        }
    }
}

// MARK: - Data Extension

extension Data {
    /// Convert data to hex string for tag identification
    var hexString: String {
        map { String(format: "%02X", $0) }.joined(separator: ":")
    }
}
