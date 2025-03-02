//
//  AWSSignV4.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/10/24.
//

import Foundation
import CryptoKit

struct Constants {
    static let RegionName = "us-east-1"
//    static let ServiceName = "aoss"
    static let Terminator = "aws4_request"
    static let Algorithm = "AWS4-HMAC-SHA256"
}

func signRequest(request: URLRequest, secretSigningKey: String, accessKeyId: String, sessionToken: String?, serviceName: String) throws -> URLRequest {
    var signedRequest = request
    let date = getDate()
    let dateShort = getDateString()
    
    guard let url = signedRequest.url, let host = url.host else { return signedRequest }

    // Add essential headers
    signedRequest.addValue(host, forHTTPHeaderField: "Host")
    signedRequest.addValue(date, forHTTPHeaderField: "X-Amz-Date")
    
    // Ensure we include the SHA256 hash of the request body
    let payloadHash = getPayloadHash(for: signedRequest)
    signedRequest.addValue(payloadHash, forHTTPHeaderField: "X-Amz-Content-Sha256")

    if let sessionToken = sessionToken {
        signedRequest.addValue(sessionToken, forHTTPHeaderField: "X-Amz-Security-Token")
    }

    // Sort headers for signing
    let headers = signedRequest.allHTTPHeaderFields ?? [:]
    let sortedHeaders = headers.map { ($0.key.lowercased(), $0.value.trimmingCharacters(in: .whitespaces)) }
        .sorted { $0.0 < $1.0 }
    
    let canonicalHeaders = sortedHeaders.map { "\($0.0):\($0.1)" }.joined(separator: "\n")
    let signedHeaders = sortedHeaders.map { $0.0 }.joined(separator: ";")
    
    // Sort query parameters
    let query = url.query?.split(separator: "&")
        .sorted()
        .joined(separator: "&") ?? ""
    
    let canonicalRequest = [
        signedRequest.httpMethod ?? "GET",
        url.path.isEmpty ? "/" : url.path, // AWS requires "/" if no path
        query,
        canonicalHeaders,
        "",
        signedHeaders,
        payloadHash
    ].joined(separator: "\n")
    
    let canonicalRequestHash = sha256Hash(canonicalRequest)
    
    // Create String to Sign
    let credentialScope = [dateShort, Constants.RegionName, serviceName, Constants.Terminator].joined(separator: "/")
    let stringToSign = [
        Constants.Algorithm,
        date,
        credentialScope,
        canonicalRequestHash
    ].joined(separator: "\n")
    
    // Generate signing key
    guard let signingKey = deriveSigningKey(secret: secretSigningKey, date: dateShort, region: Constants.RegionName, service: serviceName) else {
        return signedRequest
    }

    // Compute signature
    let signature = hmacSHA256(key: signingKey, data: stringToSign.data(using: .utf8)!).hexString

    let authorization = "\(Constants.Algorithm) Credential=\(accessKeyId)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"
    signedRequest.addValue(authorization, forHTTPHeaderField: "Authorization")

    // Debugging Output
    print("\n🔹 Canonical Request:\n\(canonicalRequest)\n")
    print("\n🔹 String to Sign:\n\(stringToSign)\n")
    print("\n🔹 Authorization Header: \(authorization)\n")

    return signedRequest
}

// MARK: - 🔑 Key Derivation (AWS Signature v4)
private func deriveSigningKey(secret: String, date: String, region: String, service: String) -> Data? {
    let kDate = hmacSHA256(key: ("AWS4" + secret).data(using: .utf8)!, data: date.data(using: .utf8)!)
    let kRegion = hmacSHA256(key: kDate, data: region.data(using: .utf8)!)
    let kService = hmacSHA256(key: kRegion, data: service.data(using: .utf8)!)
    let kSigning = hmacSHA256(key: kService, data: Constants.Terminator.data(using: .utf8)!)
    return kSigning
}

// MARK: - 🔍 Payload Hash Calculation
private func getPayloadHash(for request: URLRequest) -> String {
    guard let bodyData = request.httpBody, !bodyData.isEmpty else {
        return "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" // AWS SHA256 of empty string
    }
    return sha256Hash(String(decoding: bodyData, as: UTF8.self))
}

// MARK: - 📜 String Hashing
private func sha256Hash(_ data: String) -> String {
    let hashed = SHA256.hash(data: data.data(using: .utf8)!)
    return hashed.map { String(format: "%02x", $0) }.joined()
}

// MARK: - 🔑 HMAC-SHA256 Helper
private func hmacSHA256(key: Data, data: Data) -> Data {
    let key = SymmetricKey(data: key)
    let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
    return Data(signature)
}

// MARK: - ⏳ Date Formatting
private func getDate() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.string(from: date)
}

private func getDateString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.string(from: Date())
}

// MARK: - 🔹 Data Extensions
extension Data {
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
