/*
Copyright (c) 2023 European Commission

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Foundation
import SwiftCBOR
import Logging
import OrderedCollections

/// Contains a returned cocument. The document type of the returned document is indicated by the docType element.
public struct Document: Sendable {

	public let docType: DocType
	public let issuerSigned: IssuerSigned
	public let deviceSigned: DeviceSigned
	/// error codes for data elements that are not returned
	public let errors: Errors?

	enum Keys:String {
		case docType
		case issuerSigned
		case deviceSigned
		case errors
	}

	public init(docType: DocType, issuerSigned: IssuerSigned, deviceSigned: DeviceSigned, errors: Errors? = nil) {
		self.docType = docType
		self.issuerSigned = issuerSigned
		self.deviceSigned = deviceSigned
		self.errors = errors
	}
}

public struct W3CDocument: Sendable {
    public let docType: DocType
    public let jwt: String
    public let deviceAuth: DeviceAuth

    public let errors: Errors?

    enum Keys:String {
        case docType
        case jwt
        case deviceAuth
        case errors
    }

    public init(docType: DocType, jwt: String, deviceAuth: DeviceAuth, errors: Errors? = nil) {
        self.docType = docType
        self.jwt = jwt
        self.deviceAuth = deviceAuth
        self.errors = errors
    }
}

extension Document: CBORDecodable {
	public init(cbor: CBOR) throws(MdocValidationError) {
		guard case .map(let cd) = cbor else { throw .invalidCbor("document") }
		guard case .utf8String(let dt) = cd[Keys.docType] else { throw .missingField("Document", Keys.docType.rawValue) }
		docType = dt
		guard let cis = cd[Keys.issuerSigned] else { throw .missingField("Document", Keys.issuerSigned.rawValue) }
		issuerSigned = try IssuerSigned(cbor: cis)
		guard let cds = cd[Keys.deviceSigned] else { throw .missingField("Document", Keys.deviceSigned.rawValue) }
		deviceSigned = try DeviceSigned(cbor: cds)
		if let ce = cd[Keys.errors] { errors = try Errors(cbor: ce) } else { errors = nil }
	}
}

extension Document: CBOREncodable {
	public func toCBOR(options: CBOROptions) -> CBOR {
		var cbor = OrderedDictionary<CBOR, CBOR>()
		cbor[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
		cbor[.utf8String(Keys.issuerSigned.rawValue)] = issuerSigned.toCBOR(options: options)
		cbor[.utf8String(Keys.deviceSigned.rawValue)] = deviceSigned.toCBOR(options: options)
		if let errors = errors { cbor[.utf8String(Keys.errors.rawValue)] = errors.toCBOR(options: options) }
		return .map(cbor)
	}
}

extension W3CDocument: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case .map(let cd) = cbor else { throw .invalidCbor("document") }
        guard case .utf8String(let dt) = cd[Keys.docType] else { throw .missingField("W3CDocument", Keys.docType.rawValue) }
        docType = dt
        guard case .utf8String(let jt) = cd[Keys.jwt] else { throw .missingField("W3CDocument", Keys.jwt.rawValue) }
        jwt = jt
        guard let cda = cd[Keys.deviceAuth] else { throw .missingField("W3CDocument", Keys.deviceAuth.rawValue) }
        deviceAuth = try DeviceAuth(cbor: cda)
        if let ce = cd[Keys.errors] { errors = try Errors(cbor: ce) } else { errors = nil }
	}
}

extension W3CDocument: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var cbor = OrderedDictionary<CBOR, CBOR>()
        cbor[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        cbor[.utf8String(Keys.jwt.rawValue)] = .utf8String(jwt)
        cbor[.utf8String(Keys.deviceAuth.rawValue)] = deviceAuth.toCBOR(options: options)
        if let errors { cbor[.utf8String(Keys.errors.rawValue)] = errors.toCBOR(options: options) }
        return .map(cbor)
    }
}

extension Array where Element == W3CDocument {
    public func findDoc(name: String) -> (W3CDocument, Int)? {
        guard let index = firstIndex(where: { $0.docType == name} ) else { return nil }
        return (self[index], index)
    }
}

public struct SdJwtDocument: Sendable {
    public let docType: DocType
    public let sdJwt: String
    public let deviceAuth: DeviceAuth
    public let errors: Errors?

    enum Keys: String {
        case docType
        case sdJwt
        case deviceAuth
        case errors
    }

    public init(docType: DocType, sdJwt: String, deviceAuth: DeviceAuth, errors: Errors? = nil) {
        self.docType = docType
        self.sdJwt = sdJwt
        self.deviceAuth = deviceAuth
        self.errors = errors
    }
}

extension SdJwtDocument: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case .map(let cd) = cbor else { throw .invalidCbor("document") }
        guard case .utf8String(let dt) = cd[Keys.docType] else { throw .missingField("SdJwtDocument", Keys.docType.rawValue) }
        docType = dt
        guard case .utf8String(let sj) = cd[Keys.sdJwt] else { throw .missingField("SdJwtDocument", Keys.sdJwt.rawValue) }
        sdJwt = sj
        guard let cda = cd[Keys.deviceAuth] else { throw .missingField("SdJwtDocument", Keys.deviceAuth.rawValue) }
        deviceAuth = try DeviceAuth(cbor: cda)
        if let ce = cd[Keys.errors] { errors = try Errors(cbor: ce) } else { errors = nil }
    }
}

extension SdJwtDocument: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var cbor = OrderedDictionary<CBOR, CBOR>()
        cbor[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        cbor[.utf8String(Keys.sdJwt.rawValue)] = .utf8String(sdJwt)
        cbor[.utf8String(Keys.deviceAuth.rawValue)] = deviceAuth.toCBOR(options: options)
        if let errors { cbor[.utf8String(Keys.errors.rawValue)] = errors.toCBOR(options: options) }
        return .map(cbor)
    }
}

public struct LdpVcDocument: Sendable {
    public let docType: DocType
    public let ldpVc: String
    public let deviceAuth: DeviceAuth?
    public let errors: Errors?

    enum Keys: String {
        case docType
        case ldpVc
        case deviceAuth
        case errors
    }

    public init(docType: DocType, ldpVc: String, deviceAuth: DeviceAuth? = nil, errors: Errors? = nil) {
        self.docType = docType
        self.ldpVc = ldpVc
        self.deviceAuth = deviceAuth
        self.errors = errors
    }
}

extension LdpVcDocument: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case .map(let cd) = cbor else { throw .invalidCbor("document") }
        guard case .utf8String(let dt) = cd[Keys.docType] else { throw .missingField("LdpVcDocument", Keys.docType.rawValue) }
        docType = dt
        guard case .utf8String(let lv) = cd[Keys.ldpVc] else { throw .missingField("LdpVcDocument", Keys.ldpVc.rawValue) }
        ldpVc = lv
        if let cda = cd[Keys.deviceAuth] { deviceAuth = try DeviceAuth(cbor: cda) } else { deviceAuth = nil }
        if let ce = cd[Keys.errors] { errors = try Errors(cbor: ce) } else { errors = nil }
    }
}

extension LdpVcDocument: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        var cbor = OrderedDictionary<CBOR, CBOR>()
        cbor[.utf8String(Keys.docType.rawValue)] = .utf8String(docType)
        cbor[.utf8String(Keys.ldpVc.rawValue)] = .utf8String(ldpVc)
        if let deviceAuth { cbor[.utf8String(Keys.deviceAuth.rawValue)] = deviceAuth.toCBOR(options: options) }
        if let errors { cbor[.utf8String(Keys.errors.rawValue)] = errors.toCBOR(options: options) }
        return .map(cbor)
    }
}

public enum TransferDocument: Sendable {
    case cbor(Document)
    case w3cJwt(W3CDocument)
    case sdJwt(SdJwtDocument)
    case ldpVc(LdpVcDocument)

    public var docType: DocType {
        switch self {
        case .cbor(let d): d.docType
        case .w3cJwt(let d): d.docType
        case .sdJwt(let d): d.docType
        case .ldpVc(let d): d.docType
        }
    }
}

extension TransferDocument: CBORDecodable {
    public init(cbor: CBOR) throws(MdocValidationError) {
        guard case .map(let cd) = cbor else { throw .invalidCbor("TransferDocument") }
        if cd[.utf8String("issuerSigned")] != nil {
            self = .cbor(try Document(cbor: cbor))
        } else if cd[.utf8String("jwt")] != nil {
            self = .w3cJwt(try W3CDocument(cbor: cbor))
        } else if cd[.utf8String("sdJwt")] != nil {
            self = .sdJwt(try SdJwtDocument(cbor: cbor))
        } else if cd[.utf8String("ldpVc")] != nil {
            self = .ldpVc(try LdpVcDocument(cbor: cbor))
        } else { throw .invalidCbor("TransferDocument") }
    }
}

extension TransferDocument: CBOREncodable {
    public func toCBOR(options: CBOROptions) -> CBOR {
        switch self {
        case .cbor(let d): d.toCBOR(options: options)
        case .w3cJwt(let d): d.toCBOR(options: options)
        case .sdJwt(let d): d.toCBOR(options: options)
        case .ldpVc(let d): d.toCBOR(options: options)
        }
    }
}

extension Array where Element == TransferDocument {
    public func findDoc(name: String) -> (TransferDocument, Int)? {
        guard let index = firstIndex(where: { $0.docType == name }) else { return nil }
        return (self[index], index)
    }
}

extension Array where Element == Document {
	public func findDoc(name: String) -> (Document, Int)? {
		guard let index = firstIndex(where: { $0.docType == name} ) else { return nil }
		return (self[index], index)
	}
}

extension Array where Element == IssuerSigned {
	public func findDoc(name: String) -> (IssuerSigned, Int)? {
		guard let index = firstIndex(where: { $0.issuerAuth.mso.docType == name} ) else { return nil }
		return (self[index], index)
	}
}

extension Array where Element == DocRequest {
	public func findDoc(name: String) -> DocRequest? { first(where: { $0.itemsRequest.docType == name} ) }
}

extension Array where Element == DocClaim {
	public func findNameValue(name: String) -> DocClaim? { first(where: { $0.name == name} ) }
}
