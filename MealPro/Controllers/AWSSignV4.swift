//
//  AWSSignV4.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 11/10/24.
//

import Foundation
import CryptoKit

struct Constants {
    static let AccessKey = "your_access_key"
    static let SecretKey = "your_secret_key"
    static let RegionName = "us-east-1"
    static let ServiceName = "lambda"
    static let Terminator = "aws4_request"
    static let Algorithm = "AWS4-HMAC-SHA256"
}

func signRequest(request: URLRequest, secretSigningKey: String, accessKeyId: String, sessionToken: String?) throws -> URLRequest {
    var signedRequest = request
    let date = getDate()
    let dateShort = getDateString()
    
    guard let url = signedRequest.url, let host = url.host else { return signedRequest }
    
    signedRequest.addValue(host, forHTTPHeaderField: "Host")
    signedRequest.addValue(date, forHTTPHeaderField: "X-Amz-Date")
//    signedRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    guard let headers = signedRequest.allHTTPHeaderFields, let method = signedRequest.httpMethod else { return signedRequest }
    
    let signedHeaders = headers.map { $0.key.lowercased() }.sorted().joined(separator: ";")
    
    let payloadHash = request.httpBody?.sha256().hexString ?? sha256Hash("")
    
    let canonicalRequest = [
        method,
        url.path,
        url.query ?? "",
        headers.map { $0.key.lowercased() + ":" + $0.value }.sorted().joined(separator: "\n"),
        "",
        signedHeaders,
        payloadHash
    ].joined(separator: "\n")
    
    let canonicalRequestHash = canonicalRequest.data(using: .utf8)!.sha256().hexString
    
    let credential = [dateShort, Constants.RegionName, Constants.ServiceName, Constants.Terminator].joined(separator: "/")
    
    let stringToSign = [
        Constants.Algorithm,
        date,
        credential,
        canonicalRequestHash
    ].joined(separator: "\n")
    
    guard let signature = hmacStringToSign(stringToSign: stringToSign, secretSigningKey: secretSigningKey, shortDateString: dateShort) else { return signedRequest }
    
    let authorization = "\(Constants.Algorithm) Credential=\(accessKeyId)/\(credential), SignedHeaders=\(signedHeaders), Signature=\(signature)"
    signedRequest.addValue(authorization, forHTTPHeaderField: "Authorization")
    
    if let sessionToken = sessionToken {
        signedRequest.addValue(sessionToken, forHTTPHeaderField: "X-Amz-Security-Token")
    }
    
    return signedRequest
}
    
    private func hmacStringToSign(stringToSign: String, secretSigningKey: String, shortDateString: String) -> String? {
        let k1 = "AWS4" + secretSigningKey
        guard let sk1 = hmacSHA256(key: k1.data(using: .utf8)!, data: shortDateString.data(using: .utf8)!),
              let sk2 = hmacSHA256(key: sk1, data: Constants.RegionName.data(using: .utf8)!),
              let sk3 = hmacSHA256(key: sk2, data: Constants.ServiceName.data(using: .utf8)!),
              let sk4 = hmacSHA256(key: sk3, data: Constants.Terminator.data(using: .utf8)!),
              let signature = hmacSHA256(key: sk4, data: stringToSign.data(using: .utf8)!)
        else { return nil }
        
        return signature.map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func hmacSHA256(key: Data, data: Data) -> Data? {
        let key = SymmetricKey(data: key)
        let signature = HMAC<SHA256>.authenticationCode(for: data, using: key)
        return Data(signature)
    }
    
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
    
    private func sha256Hash(_ data: String) -> String {
        return data.data(using: .utf8)!.sha256().hexString
    }

extension Data {
    func sha256() -> Data {
        let hash = SHA256.hash(data: self)
        return Data(hash)
    }
    
    var hexString: String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}
