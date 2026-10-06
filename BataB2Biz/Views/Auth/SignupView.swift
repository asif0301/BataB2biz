//
//  SignupView.swift
//  BataB2Biz
//

import SwiftUI
import UniformTypeIdentifiers
import Foundation
import PhotosUI
import UIKit

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var businessName = ""
    @State private var contactName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var city = ""
    @State private var address = ""
    @State private var deliveryAddress = ""
    @State private var bankDetails = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var businessType = "Wholesale"
    @State private var channelType = "Direct Retail"
    @State private var showingFileImporter = false
    @State private var showingUploadOptions = false
    @State private var showingPhotosPicker = false
    @State private var showingCamera = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var uploadTarget: UploadTarget?
    @State private var profileImageName: String?
    @State private var businessLicenseName: String?
    @State private var tradeLicenseName: String?
    @State private var profileImageData: Data?
    @State private var businessLicenseData: Data?
    @State private var tradeLicenseData: Data?
    @State private var passwordIsVisible = false
    @State private var confirmPasswordIsVisible = false
    @State private var isSubmitting = false
    @State private var showingMessage = false
    @State private var message = ""
    @State private var errors: [String: String?] = [:]
    private let authRepository = AuthRepository()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.title)
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)

                    Text(AppStrings.Signup.title)
                        .montserrat(17, weight: .bold)
                        .foregroundStyle(AppColors.title)

                    Spacer()
                }
                .padding(.top, 12)

                Image(AppImages.bataLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 192, height: 44)
                    .padding(.top, 21)
                    .padding(.bottom, 17)

                Text(AppStrings.Signup.welcome)
                    .montserrat(19, weight: .bold)
                    .foregroundStyle(AppColors.title)

                Text("Create to your business account")
                    .montserrat(12)
                    .foregroundStyle(AppColors.subtitle)
                    .padding(.top, 5)
                    .padding(.bottom, 18)

                Button {
                    prepareUpload(.profile)
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: profileImageName == nil ? "arrow.up.to.line" : "checkmark.circle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(AppColors.primary)
                        Text(profileImageName == nil ? "Upload Profile Image\n(Required)" : profileImageName!)
                            .montserrat(13)
                            .foregroundStyle(AppColors.subtitle)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(width: 190, height: 190)
                    .overlay {
                        Circle()
                            .stroke(AppColors.border, style: StrokeStyle(lineWidth: 2, dash: [7, 5]))
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 23)

                VStack(spacing: 10) {
                    AppTextField(icon: nil, placeholder: AppStrings.Signup.businessName, text: $businessName)
                    AppTextField(icon: nil, placeholder: "Name", text: $contactName)
                    AppTextField(icon: "phone", placeholder: AppStrings.Signup.phone, text: $phone, keyboardType: .phonePad)
                    AppTextField(icon: "envelope", placeholder: AppStrings.Signup.email, text: $email, keyboardType: .emailAddress)
                    AppTextField(icon: "building.2", placeholder: AppStrings.Signup.city, text: $city)
                    AppTextField(icon: "mappin.circle", placeholder: AppStrings.Signup.address, text: $address)
                    AppTextField(icon: nil, placeholder: "Delivery Address", text: $deliveryAddress)
                    AppTextField(icon: nil, placeholder: "Bank Details", text: $bankDetails)
                    SignupPasswordField(title: "Password", text: $password, isVisible: $passwordIsVisible)
                    SignupPasswordField(title: "Confirm Password", text: $confirmPassword, isVisible: $confirmPasswordIsVisible)
                }

                SignupChoiceSection(title: AppStrings.Signup.businessType, choices: ["Retail", "Wholesale", "Key Account"], selection: $businessType, columnCount: 3)
                    .padding(.top, 11)
                SignupChoiceSection(title: AppStrings.Signup.channelType, choices: ["Direct Retail", "Wholesale"], selection: $channelType, columnCount: 2)
                    .padding(.top, 9)

                HStack(spacing: 8) {
                    LicenseUploadButton(title: "Upload Business License", fileName: businessLicenseName) {
                        prepareUpload(.businessLicense)
                    }
                    LicenseUploadButton(title: "Upload Trade License", fileName: tradeLicenseName) {
                        prepareUpload(.tradeLicense)
                    }
                }
                .padding(.top, 10)

                AppButton(
                    title: AppStrings.Signup.submit,
                    isFilled: true,
                    action: submitRegistration,
                    isLoading: isSubmitting,
                    isDisabled: isSubmitting
                )
                .padding(.top, 10)

                HStack(spacing: 4) {
                    Text(AppStrings.Signup.existingAccount)
                        .montserrat(12)
                        .foregroundStyle(AppColors.subtitle)
                    Button(AppStrings.Signup.login) { dismiss() }
                        .montserrat(12, weight: .semibold)
                        .foregroundStyle(AppColors.primary)
                }
                .padding(.top, 19)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("Upload Document", isPresented: $showingUploadOptions, titleVisibility: .visible) {
            Button("Choose from Gallery") {
                showingPhotosPicker = true
            }
            Button("Take Photo") {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showingCamera = true
                } else {
                    showingPhotosPicker = true
                }
            }
            Button("Choose File") {
                showingFileImporter = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .photosPicker(isPresented: $showingPhotosPicker, selection: $selectedPhoto, matching: .images)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: uploadTarget == .profile ? [.image] : [.pdf, .image]) { result in
            if case .success(let url) = result, let uploadTarget {
                let data = try? Data(contentsOf: url)
                saveUpload(data: data, fileName: url.lastPathComponent, for: uploadTarget)
            }
            uploadTarget = nil
        }
        .sheet(isPresented: $showingCamera) {
            CameraImagePicker(
                onImagePicked: { data in
                    saveUpload(data: data, fileName: "camera-image.jpg", for: uploadTarget)
                    showingCamera = false
                },
                onCancel: {
                    showingCamera = false
                }
            )
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task {
                let data = try? await item.loadTransferable(type: Data.self)
                await MainActor.run {
                    saveUpload(data: data, fileName: "gallery-image.jpg", for: uploadTarget)
                    selectedPhoto = nil
                }
            }
        }
        .alert("Bata B2B", isPresented: $showingMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(message)
        }
    }

    private func prepareUpload(_ target: UploadTarget) {
        uploadTarget = target
        showingUploadOptions = true
    }

    private func saveUpload(data: Data?, fileName: String, for target: UploadTarget?) {
        guard let data, let target else { return }
        let upload = optimizedUpload(data: data, fileName: fileName)
        switch target {
        case .profile:
            profileImageName = upload.fileName
            profileImageData = upload.data
        case .businessLicense:
            businessLicenseName = upload.fileName
            businessLicenseData = upload.data
        case .tradeLicense:
            tradeLicenseName = upload.fileName
            tradeLicenseData = upload.data
        }
        uploadTarget = nil
    }

    private func optimizedUpload(data: Data, fileName: String) -> (data: Data, fileName: String) {
        guard !fileName.lowercased().hasSuffix(".pdf"), let image = UIImage(data: data) else {
            return (data, fileName)
        }

        let maxDimension: CGFloat = 1600
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedData = renderer.jpegData(withCompressionQuality: 0.72) { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        let qualityLevels: [CGFloat] = [0.75, 0.60, 0.45, 0.30, 0.18]
        let compressedData = qualityLevels
            .compactMap { image.jpegData(compressionQuality: $0) }
            .first(where: { $0.count <= 1_900_000 }) ?? resizedData

        let baseName = URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
        return (compressedData, "\(baseName).jpg")
    }

    private func submitRegistration() {
        guard validateForm() else { return }

        isSubmitting = true
        let form = RegistrationForm(
            businessName: businessName.trimmingCharacters(in: .whitespacesAndNewlines),
            contactName: contactName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city.trimmingCharacters(in: .whitespacesAndNewlines),
            address: address.trimmingCharacters(in: .whitespacesAndNewlines),
            deliveryAddress: deliveryAddress.trimmingCharacters(in: .whitespacesAndNewlines),
            bankDetails: bankDetails.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            confirmPassword: confirmPassword,
            businessType: apiBusinessType,
            channelType: apiChannelType,
            profileImageData: profileImageData!,
            profileImageName: profileImageName!,
            businessLicenseData: businessLicenseData!,
            businessLicenseName: businessLicenseName!,
            tradeLicenseData: tradeLicenseData!,
            tradeLicenseName: tradeLicenseName!
        )

        Task {
            do {
                let response = try await authRepository.register(
                    businessName: form.businessName,
                    contactPersonName: form.contactName,
                    phone: form.phone,
                    email: form.email,
                    city: form.city,
                    businessAddress: form.address,
                    deliveryAddress: form.deliveryAddress,
                    bankDetails: form.bankDetails,
                    password: form.password,
                    confirmPassword: form.confirmPassword,
                    businessType: form.businessType,
                    channelType: form.channelType,
                    profileImage: form.profileImage,
                    businessLicense: form.businessLicense,
                    tradeLicense: form.tradeLicense
                )
                message = response.message
                showingMessage = true
            } catch {
                message = error.localizedDescription
                showingMessage = true
            }
            isSubmitting = false
        }
    }

    private func validateForm() -> Bool {
        var nextErrors: [String: String?] = [:]
        nextErrors["businessName"] = requiredError(businessName, label: "Business Name")
        nextErrors["contactPerson"] = requiredError(contactName, label: "Contact Person Name")
        nextErrors["phone"] = validatePhone(phone)
        nextErrors["email"] = validateEmail(email)
        nextErrors["city"] = requiredError(city, label: "City")
        nextErrors["address"] = requiredError(address, label: "Business Address")
        nextErrors["deliveryAddress"] = requiredError(deliveryAddress, label: "Delivery Address")
        nextErrors["bankDetails"] = requiredError(bankDetails, label: "Bank Details")
        nextErrors["password"] = validatePassword(password)
        nextErrors["confirmPassword"] = password == confirmPassword ? nil : "Passwords do not match."
        nextErrors["profileImage"] = profileImageData == nil ? "Profile image is required." : nil
        nextErrors["businessLicense"] = businessLicenseData == nil ? "Business license is required." : nil
        nextErrors["tradeLicense"] = tradeLicenseData == nil ? "Trade license is required." : nil
        errors = nextErrors

        for error in nextErrors.values {
            if let error {
                message = error
                showingMessage = true
                return false
            }
        }
        return true
    }

    private func requiredError(_ value: String, label: String) -> String? {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "\(label) is required." : nil
    }

    private func validatePhone(_ value: String) -> String? {
        let digits = value.filter(\.isNumber)
        return digits.count >= 7 && digits.count <= 15 ? nil : "Please enter a valid phone number."
    }

    private func validateEmail(_ value: String) -> String? {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) == nil ? "Please enter a valid email address." : nil
    }

    private func validatePassword(_ value: String) -> String? {
        guard value.count >= 8 else { return "Password must be at least 8 characters." }
        guard value.range(of: "[A-Z]", options: .regularExpression) != nil,
              value.range(of: "[a-z]", options: .regularExpression) != nil,
              value.range(of: "[0-9]", options: .regularExpression) != nil else {
            return "Password must include uppercase, lowercase, and a number."
        }
        return nil
    }

    private var apiBusinessType: String {
        businessType.lowercased().replacingOccurrences(of: " ", with: "_")
    }

    private var apiChannelType: String {
        channelType.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}

private struct RegistrationForm {
    let businessName: String
    let contactName: String
    let phone: String
    let email: String
    let city: String
    let address: String
    let deliveryAddress: String
    let bankDetails: String
    let password: String
    let confirmPassword: String
    let businessType: String
    let channelType: String
    let profileImageData: Data
    let profileImageName: String
    let businessLicenseData: Data
    let businessLicenseName: String
    let tradeLicenseData: Data
    let tradeLicenseName: String

    var profileImage: MultipartFile { MultipartFile(fieldName: "profile_image", fileName: profileImageName, mimeType: profileImageName.mimeType, data: profileImageData) }
    var businessLicense: MultipartFile { MultipartFile(fieldName: "business_license", fileName: businessLicenseName, mimeType: businessLicenseName.mimeType, data: businessLicenseData) }
    var tradeLicense: MultipartFile { MultipartFile(fieldName: "trade_license", fileName: tradeLicenseName, mimeType: tradeLicenseName.mimeType, data: tradeLicenseData) }
}

private extension String {
    var mimeType: String {
        switch lowercased().split(separator: ".").last {
        case "pdf": "application/pdf"
        case "png": "image/png"
        case "heic": "image/heic"
        default: "image/jpeg"
        }
    }
}

private enum UploadTarget: Equatable {
    case profile, businessLicense, tradeLicense
}

private struct SignupChoiceSection: View {
    let title: String
    let choices: [String]
    @Binding var selection: String
    let columnCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .montserrat(12, weight: .semibold)
                .foregroundStyle(AppColors.title)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columnCount), spacing: 8) {
                ForEach(choices, id: \.self) { choice in
                    Button { selection = choice } label: {
                        Text(choice)
                            .montserrat(12, weight: selection == choice ? .medium : .regular)
                            .foregroundStyle(selection == choice ? .white : AppColors.title)
                            .frame(maxWidth: .infinity)
                            .frame(height: 32)
                            .background(selection == choice ? AppColors.primary : AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct SignupPasswordField: View {
    let title: String
    @Binding var text: String
    @Binding var isVisible: Bool

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: "lock")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.subtitle)
                .frame(width: 20)

            Group {
                if isVisible {
                    TextField(title, text: $text)
                } else {
                    SecureField(title, text: $text)
                }
            }
            .montserrat(14)

            Button { isVisible.toggle() } label: {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.subtitle)
            }
            .buttonStyle(.plain)
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

private struct LicenseUploadButton: View {
    let title: String
    let fileName: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: fileName == nil ? "arrow.up.to.line" : "checkmark.circle.fill")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                Text(fileName ?? "\(title)\n(Required)")
                    .montserrat(11)
                    .foregroundStyle(AppColors.subtitle)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 86)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }
        }
        .buttonStyle(.plain)
    }
}

private struct CameraImagePicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (Data) -> Void
        let onCancel: () -> Void

        init(onImagePicked: @escaping (Data) -> Void, onCancel: @escaping () -> Void) {
            self.onImagePicked = onImagePicked
            self.onCancel = onCancel
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 0.85) {
                onImagePicked(data)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    SignupView()
}
