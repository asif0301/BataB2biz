//
//  MainTabView.swift
//  BataB2Biz
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = AppTab.home
    @State private var homeReloadID = UUID()

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(showsBottomBar: false)
                        .id(homeReloadID)
                case .category:
                    CategoryView(showsBottomBar: false)
                        .id(AppTab.category)
                case .quickOrder:
                    PlaceholderTabView(title: "Quick Order", icon: "bolt.fill")
                case .offers:
                    OffersView(showsBottomBar: false)
                case .profile:
                    ProfileView(showsBottomBar: false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomBottomBar(selectedTab: $selectedTab) { tab in
                if tab == .home {
                    homeReloadID = UUID()
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .home {
                homeReloadID = UUID()
            }
        }
    }
}

private struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(AppColors.primary)
            Text(title)
                .montserrat(20, weight: .bold)
                .foregroundStyle(AppColors.title)
            Text("This section is coming soon.")
                .montserrat(13)
                .foregroundStyle(AppColors.subtitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MainTabView()
}
