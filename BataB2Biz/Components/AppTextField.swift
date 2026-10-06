//
//  AppTextField.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import SwiftUI

struct AppTextField: View {
    let icon: String?
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 11) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(AppColors.subtitle)
                    .frame(width: 20)
            }

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .keyboardType(keyboardType)
                }
            }
            .montserrat(14)
            .foregroundStyle(AppColors.title)
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(AppColors.background)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AppTextField(icon: "envelope", placeholder: "Email or Phone", text: .constant(""))
        .padding()
}
