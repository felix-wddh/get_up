import Foundation
import CryptoKit

// Mocking the logic from NFCService.swift
func generateTagHash(from identifier: String) -> String {
    let data = Data(identifier.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}

func verifyTag(scannedHash: String, expectedHash: String) -> Bool {
    guard scannedHash.count == expectedHash.count else { return false }
    var result: UInt8 = 0
    for (a, b) in zip(scannedHash.utf8, expectedHash.utf8) {
        result |= a ^ b
    }
    return result == 0
}

// Tests
print("🧪 Running Unit Tests for Hashing & Verification...")

let testTagId = "MOCK-TAG-123"
let hash = generateTagHash(from: testTagId)
print("1. Hashing logic: \(hash.prefix(16))...")

// Test 1: Determinism
let hash2 = generateTagHash(from: testTagId)
assert(hash == hash2, "❌ Hashing is not deterministic")
print("✅ Test 1: Hashing is deterministic")

// Test 2: Verification (Success)
let isVerified = verifyTag(scannedHash: hash, expectedHash: hash2)
assert(isVerified == true, "❌ Verification failed for matching hashes")
print("✅ Test 2: Verification succeeds for matching hashes")

// Test 3: Verification (Failure)
let wrongHash = generateTagHash(from: "WRONG-TAG")
let isVerifiedWrong = verifyTag(scannedHash: wrongHash, expectedHash: hash)
assert(isVerifiedWrong == false, "❌ Verification succeeded for non-matching hashes")
print("✅ Test 3: Verification fails for non-matching hashes")

// Test 4: Privacy (No raw ID in hash)
assert(!hash.contains(testTagId), "❌ Hash contains raw identifier")
print("✅ Test 4: Privacy check - hash does not contain raw identifier")

print("\n🎉 All logic tests passed!")
