//
//  LoginView.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                Image(AppImages.bataLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 192, height: 44)
                    .padding(.top, 102)
                    .padding(.bottom, 17)

                Text(AppStrings.Login.welcomeBack)
                    .montserrat(19, weight: .bold)
                    .foregroundStyle(AppColors.title)

                Text(AppStrings.Login.subtitle)
                    .montserrat(12)
                    .foregroundStyle(AppColors.subtitle)
                    .padding(.top, 5)
                    .padding(.bottom, 25)

                VStack(spacing: 12) {
                    AppTextField(icon: "envelope", placeholder: AppStrings.Login.emailPlaceholder, text: $viewModel.email)
                    AppTextField(icon: "lock", placeholder: AppStrings.Login.passwordPlaceholder, text: $viewModel.password, isSecure: true)
                }

                HStack {
                    Button {
                        viewModel.rememberMe.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
                                .font(.system(size: 15))
                                .foregroundStyle(viewModel.rememberMe ? AppColors.primary : AppColors.subtitle)
                            Text(AppStrings.Login.rememberMe)
                                .montserrat(12)
                                .foregroundStyle(AppColors.title)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(AppStrings.Login.forgotPassword) {
                        viewModel.message = "Password reset instructions will be sent to your registered contact."
                        viewModel.showingMessage = true
                    }
                    .montserrat(12)
                    .foregroundStyle(AppColors.primary)
                }
                .padding(.top, 11)
                .padding(.bottom, 13)

                VStack(spacing: 12) {
                    AppButton(title: AppStrings.Login.login, isFilled: true, action: viewModel.login, isLoading: viewModel.isLoading, isDisabled: viewModel.isLoading)
                    AppButton(title: AppStrings.Login.loginWithOTP, isFilled: false, action: viewModel.requestOTP)
                }

                HStack(spacing: 4) {
                    Text(AppStrings.Login.newHere)
                        .montserrat(12)
                        .foregroundStyle(AppColors.subtitle)
                    NavigationLink(AppStrings.Login.register) {
                        SignupView()
                    }
                        .montserrat(12, weight: .semibold)
                        .foregroundStyle(AppColors.primary)
                }
                .padding(.top, 19)
            }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $viewModel.loginSucceeded) {
                MainTabView()
            }
            .alert("Bata B2B", isPresented: $viewModel.showingMessage) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.message)
            }
            .overlay(alignment: .top) {
                if !viewModel.toastMessage.isEmpty {
                    LoginToast(message: viewModel.toastMessage, isSuccess: viewModel.toastIsSuccess)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
}

private struct LoginToast: View {
    let message: String
    let isSuccess: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
            Text(message)
                .montserrat(12, weight: .medium)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(isSuccess ? Color(red: 0.10, green: 0.55, blue: 0.28) : AppColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.14), radius: 10, y: 4)
    }
}

#Preview {
    LoginView()
}
