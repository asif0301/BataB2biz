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
        case .category: "square.grid.3x3"
        case .quickOrder: "bolt"
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
        HStack(alignment: .top, spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                    onSelect(tab)
                } label: {
                    VStack(spacing: 5) {
                        ZStack(alignment: .bottom) {
                            if tab == .quickOrder {
                            Image(systemName: tab.icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(AppColors.primary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.12), radius: 6, y: 5)
                            } else {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 21, weight: .regular))
                                    .frame(height: 24)
                                    .padding(.bottom, 3)
                            }
                        }
                        .frame(height: 56, alignment: .bottom)
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: .regular))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(height: 17)
                    }
                    .foregroundStyle(tab == selectedTab && tab != .quickOrder ? AppColors.primary : Color(red: 0.61, green: 0.64, blue: 0.69))
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(tab == selectedTab ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
        .background {
            VStack(spacing: 0) {
                Color.clear.frame(height: 15)
                Color.white
                    .overlay(alignment: .top) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.08))
                            .frame(height: 1)
                    }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    CustomBottomBar(selectedTab: .constant(.offers))
}
