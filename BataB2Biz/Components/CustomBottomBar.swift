//
//  CustomBottomBar.swift
//  BataB2Biz
//

import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case category = "Category"
    case quickOrder = "Quick Order"
    case offers = "Offers"
    case profile = "Profile"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .home: "house"
        case .category: "square.grid.2x2"
        case .quickOrder: "bolt.fill"
        case .offers: "tag"
        case .profile: "person"
        }
    }
}

struct CustomBottomBar: View {
    @Binding var selectedTab: AppTab
    let onSelect: (AppTab) -> Void

    init(selectedTab: Binding<AppTab>, onSelect: @escaping (AppTab) -> Void = { _ in }) {
        self._selectedTab = selectedTab
        self.onSelect = onSelect
    }

    var body: some View {
        HStack {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                    onSelect(tab)
                } label: {
                    VStack(spacing: 4) {
                        if tab == .quickOrder {
                            Image(systemName: tab.icon)
                                .font(.system(size: 21, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 52, height: 52)
                                .background(AppColors.primary)
                                .clipShape(Circle())
                                .shadow(color: AppColors.primary.opacity(0.24), radius: 7, y: 4)
                                .offset(y: -17)
                        } else {
                            Image(systemName: tab.icon)
                                .font(.system(size: 17, weight: .medium))
                        }

                        Text(tab.rawValue)
                            .montserrat(10, weight: tab == selectedTab ? .semibold : .regular)
                    }
                    .foregroundStyle(tab == selectedTab ? AppColors.primary : AppColors.subtitle)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(.white)
        .overlay(alignment: .top) { Divider().overlay(AppColors.border) }
    }
}

#Preview {
    CustomBottomBar(selectedTab: .constant(.home))
}
