//
//  AuthRepository.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation

final class AuthRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func login(identifier: String, password: String, remember: Bool) async throws -> LoginResponse {
        let request = LoginRequest(
            identifier: identifier,
            password: password,
            deviceName: "iOS App",
            remember: remember,
            deviceToken: DeviceTokenProvider.value
        )

        return try await networkManager.post(request, to: APIService.Endpoint.login)
    }

    func register(
        businessName: String,
        contactPersonName: String,
        phone: String,
        email: String,
        city: String,
        businessAddress: String,
        deliveryAddress: String,
        bankDetails: String,
        password: String,
        confirmPassword: String,
        businessType: String,
        channelType: String,
        profileImage: MultipartFile?,
        businessLicense: MultipartFile?,
        tradeLicense: MultipartFile?
    ) async throws -> RegisterResponse {
        let fields = [
            "business_name": businessName,
            "name": contactPersonName,
            "phone": phone,
            "email": email,
            "city": city,
            "business_address": businessAddress,
            "delivery_address": deliveryAddress,
            "bank_details": bankDetails,
            "password": password,
            "password_confirmation": confirmPassword,
            "business_type": businessType,
            "channel_type": channelType,
            "device_token": DeviceTokenProvider.value
        ]

        return try await networkManager.postMultipart(
            fields: fields,
            files: [profileImage, businessLicense, tradeLicense].compactMap { $0 },
            to: APIService.Endpoint.register
        )
    }
}

private enum DeviceTokenProvider {
    private static let key = "bata.deviceToken"

    static var value: String {
        if let token = UserDefaults.standard.string(forKey: key) {
            return token
        }
        let token = UUID().uuidString
        UserDefaults.standard.set(token, forKey: key)
        return token
    }
}
