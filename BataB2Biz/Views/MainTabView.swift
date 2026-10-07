//
//  MainTabView.swift
//  BataB2Biz
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = AppTab.home

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView(showsBottomBar: false)
                case .category:
                    CategoryView(showsBottomBar: false)
                case .quickOrder:
                    PlaceholderTabView(title: "Quick Order", icon: "bolt.fill")
                case .offers:
                    PlaceholderTabView(title: "Offers", icon: "tag")
                case .profile:
                    PlaceholderTabView(title: "Profile", icon: "person")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomBottomBar(selectedTab: $selectedTab)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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
