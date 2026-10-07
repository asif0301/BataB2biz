//
//  LoginViewModel.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {
    private let authRepository: AuthRepository
    var email = ""
    var password = ""
    var rememberMe = false
    var isLoading = false
    var loginSucceeded = false
    var toastMessage = ""
    var toastIsSuccess = false
    var showingMessage = false
    var message = ""

    init(authRepository: AuthRepository = AuthRepository()) {
        self.authRepository = authRepository
    }

    func login() {
        let identifier = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty,
              !password.isEmpty else {
            showToast("Please enter your email or phone and password.", isSuccess: false)
            return
        }

        guard !isLoading else { return }
        isLoading = true

        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await authRepository.login(identifier: identifier, password: password, remember: rememberMe)
                guard response.success, let data = response.data else {
                    showToast(response.message, isSuccess: false)
                    isLoading = false
                    return
                }

                UserDefaults.standard.set(data.token.value, forKey: "bata.authToken")
                UserDefaults.standard.set(data.user.id, forKey: "bata.userId")
                UserDefaults.standard.set(rememberMe, forKey: "bata.rememberMe")
                loginSucceeded = true
                showToast(response.message, isSuccess: true)
            } catch {
                showToast(error.localizedDescription, isSuccess: false)
            }
            isLoading = false
        }
    }

    func requestOTP() {
        message = "We’ll send a one-time password to your registered contact."
        showingMessage = true
    }

    private func showToast(_ text: String, isSuccess: Bool) {
        toastMessage = text
        toastIsSuccess = isSuccess

        Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard let self, toastMessage == text else { return }
            toastMessage = ""
        }
    }
}
