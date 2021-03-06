import Crypto
import Foundation

/// The algorithm to use for signing
public protocol JWTAlgorithm {
    /// Unique JWT-standard name for this algorithm.
    var jwtAlgorithmName: String { get }

    /// Creates a signature from the supplied plaintext.
    func sign(_ plaintext: LosslessDataConvertible) throws -> Data

    /// Returns true if the signature was creating by signing the plaintext.
    func verify(_ signature: LosslessDataConvertible, signs plaintext: LosslessDataConvertible) throws -> Bool
}

extension JWTAlgorithm {
    /// See `JWTAlgorithm.verify(_:signs)`
    public func verify(_ signature: LosslessDataConvertible, signs plaintext: LosslessDataConvertible) throws -> Bool {
        return try sign(plaintext) == signature.convertToData()
    }
}

/// Convenience struct for `JWTAlgorithm` conformance.
public struct CustomJWTAlgorithm: JWTAlgorithm {
    /// See `JWTAlgorithm`.
    public let jwtAlgorithmName: String

    /// See `JWTAlgorithm`.
    private let signClosure: (LosslessDataConvertible) throws -> Data

    /// See `JWTAlgorithm`.
    private let verifyClosure: (LosslessDataConvertible, LosslessDataConvertible) throws -> Bool

    /// Create a new `CustomJWTAlgorithm`.
    public init(
        name: String,
        sign: @escaping (LosslessDataConvertible) throws -> Data,
        verify: @escaping (LosslessDataConvertible, LosslessDataConvertible) throws -> Bool
    ) {
        self.jwtAlgorithmName = name
        self.signClosure = sign
        self.verifyClosure = verify
    }

    /// See `JWTAlgorithm`.
    public func sign(_ plaintext: LosslessDataConvertible) throws -> Data {
        return try signClosure(plaintext)
    }

    /// See `JWTAlgorithm`.
    public func verify(_ signature: LosslessDataConvertible, signs plaintext: LosslessDataConvertible) throws -> Bool {
        return try verifyClosure(signature, plaintext)
    }
}
