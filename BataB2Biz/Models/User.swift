//
//  User.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation

struct LoginRequest: Encodable {
    let identifier: String
    let password: String
    let deviceName: String
    let remember: Bool
    let deviceToken: String

    enum CodingKeys: String, CodingKey {
        case identifier, password, remember
        case deviceName = "device_name"
        case deviceToken = "device_token"
    }
}

struct LoginResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: LoginData?
}

struct RegisterResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
}

struct LoginData: Decodable {
    let user: User
    let token: AuthToken
}

struct AuthToken: Decodable {
    let type: String
    let name: String
    let value: String
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case type, name, value
        case expiresAt = "expires_at"
    }
}

struct User: Decodable {
    let id: Int
    let name: String
    let email: String?
    let phone: String?
    let role: String
    let status: Int
    let statusChangedBy: Int?
    let statusChangedAt: String?
    let source: String?
    let profileImage: String?
    let deviceToken: String?
    let businessName: String?
    let businessType: String?
    let businessTypes: [String]
    let channelType: String?
    let businessLicense: String?
    let tradeLicense: String?
    let contactPersonName: String?
    let contactPersonPhone: String?
    let businessAddress: String?
    let city: String?
    let deliveryAddress: String?
    let bankDetails: String?
    let channelName: String?
    let channelScopeId: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, role, status, source, city
        case statusChangedBy = "status_changed_by"
        case statusChangedAt = "status_changed_at"
        case profileImage = "profile_image"
        case deviceToken = "device_token"
        case businessName = "business_name"
        case businessType = "business_type"
        case businessTypes = "business_types"
        case channelType = "channel_type"
        case businessLicense = "business_license"
        case tradeLicense = "trade_license"
        case contactPersonName = "contact_person_name"
        case contactPersonPhone = "contact_person_phone"
        case businessAddress = "business_address"
        case deliveryAddress = "delivery_address"
        case bankDetails = "bank_details"
        case channelName = "channel_name"
        case channelScopeId = "channel_scope_id"
    }
}
