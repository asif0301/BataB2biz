//
//  AppButton.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import SwiftUI

struct AppButton: View {
    let title: String
    let isFilled: Bool
    let action: () -> Void
    var isLoading = false
    var isDisabled = false

    var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(isFilled ? .white : AppColors.primary)
                } else {
                    Text(title)
                        .montserrat(15, weight: .semibold)
                }
            }
            .foregroundStyle(isFilled ? .white : AppColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(isFilled ? AppColors.primary : AppColors.background)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primary, lineWidth: isFilled ? 0 : 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.7 : 1)
    }
}

#Preview {
    AppButton(title: "Login", isFilled: true, action: {})
        .padding()
}
