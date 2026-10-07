import SwiftUI

struct ProfileView: View {
    var showsBottomBar = false
    @State private var viewModel = ProfileViewModel()
    @State private var selectedTab = AppTab.profile
    @AppStorage("bata.authToken") private var authToken = ""
    @AppStorage("bata.rememberMe") private var rememberMe = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    if viewModel.isLoading && viewModel.profile == nil {
                        ProfileLoadingView()
                    } else if let profile = viewModel.profile {
                        profileContent(profile)
                    } else if !viewModel.errorMessage.isEmpty {
                        errorView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            .refreshable { viewModel.loadProfile() }
            if showsBottomBar { CustomBottomBar(selectedTab: $selectedTab) }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { viewModel.loadProfile() }
    }

    private var header: some View {
        HStack {
            Text("My Profile")
                .montserrat(17, weight: .bold)
                .foregroundStyle(AppColors.title)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 19))
                .foregroundStyle(AppColors.subtitle)
        }
        .padding(.bottom, 30)
    }

    private func profileContent(_ profile: ProfileData) -> some View {
        VStack(spacing: 0) {
            profileHeader(profile.user)
            contactCard(profile.user)
                .padding(.top, 36)
            actionRows
                .padding(.top, 16)
            buttons
                .padding(.top, 8)
            Text("Version 1.0.0")
                .montserrat(12)
                .foregroundStyle(AppColors.subtitle)
                .padding(.top, 16)
        }
    }

    private func profileHeader(_ user: ProfileUser) -> some View {
        VStack(spacing: 10) {
            avatar(user)
            Text(user.businessName ?? user.name)
                .montserrat(19, weight: .bold)
                .foregroundStyle(AppColors.title)
            Text("\(user.businessType?.capitalized ?? "") · \(user.city ?? "")")
                .montserrat(12)
                .foregroundStyle(AppColors.subtitle)
            Button { } label: {
                Label("Edit Profile", systemImage: "pencil")
                    .montserrat(12, weight: .bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func avatar(_ user: ProfileUser) -> some View {
        Group {
            if let image = user.profileImage, let url = URL(string: image) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: { initials(user) }
            } else {
                initials(user)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    }

    private func initials(_ user: ProfileUser) -> some View {
        Text(initialsText(user.name))
            .montserrat(24, weight: .bold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.primary)
    }

    private func contactCard(_ user: ProfileUser) -> some View {
        VStack(spacing: 9) {
            profileValue("Contact", user.contactPersonName ?? user.name)
            profileValue("Phone", user.phone)
            profileValue("Email", user.email)
            profileValue("Type", user.businessType?.capitalized ?? "")
        }
        .padding(16)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private func profileValue(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).montserrat(13).foregroundStyle(AppColors.subtitle)
            Spacer()
            Text(value)
                .montserrat(13, weight: title == "Type" ? .bold : .regular)
                .foregroundStyle(title == "Type" ? AppColors.primary : AppColors.title)
                .lineLimit(1)
        }
    }

    private var actionRows: some View {
        VStack(spacing: 8) {
            profileRow("heart", "Favourite")
            profileRow("mappin", "Address Management")
            profileRow("gearshape", "Settings")
            profileRow("bell", "Notification Settings")
            profileRow("questionmark.circle", "Support / FAQ")
            profileRow("doc.text", "Terms & Conditions")
        }
    }

    private func profileRow(_ icon: String, _ title: String) -> some View {
        Button { } label: {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 18)
                Text(title).montserrat(14).foregroundStyle(AppColors.title)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(AppColors.subtitle)
            }
            .padding(.horizontal, 14)
            .frame(height: 46)
            .overlay { RoundedRectangle(cornerRadius: 11).stroke(AppColors.border, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }

    private var buttons: some View {
        VStack(spacing: 8) {
            Button { } label: {
                Label("Delete Account", systemImage: "person.badge.minus")
                    .montserrat(13, weight: .bold)
                    .foregroundStyle(AppColors.primary)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .overlay { RoundedRectangle(cornerRadius: 11).stroke(AppColors.primary, lineWidth: 1) }
            }
            Button {
                authToken = ""
                rememberMe = false
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                    .montserrat(13, weight: .bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 11))
            }
        }
        .buttonStyle(.plain)
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28)).foregroundStyle(AppColors.primary)
            Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle)
            Button("Try Again") { viewModel.loadProfile() }
                .montserrat(13, weight: .semibold).foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 100)
    }

    private func initialsText(_ name: String) -> String {
        name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined().uppercased()
    }
}

private struct ProfileLoadingView: View {
    var body: some View {
        VStack(spacing: 14) {
            SkeletonBlock(width: 80, height: 80, cornerRadius: 40)
            SkeletonBlock(width: 130, height: 20)
            SkeletonBlock(width: 150, height: 14)
            SkeletonBlock(width: nil, height: 130, cornerRadius: 13)
            ForEach(0..<6, id: \.self) { _ in SkeletonBlock(width: nil, height: 46, cornerRadius: 11) }
        }
        .padding(.top, 14)
    }
}

#Preview { ProfileView() }
