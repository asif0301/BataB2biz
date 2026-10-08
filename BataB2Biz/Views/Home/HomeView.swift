//
//  HomeView.swift
//  BataB2Biz
//

import SwiftUI

struct HomeView: View {
    var showsBottomBar = false
    @State private var viewModel = HomeViewModel()
    @State private var selectedTab = AppTab.home
    @State private var showingCategory = false
    @State private var showingCart = false
    @State private var showingOrders = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header

                    if viewModel.isLoading && viewModel.home == nil {
                        HomeLoadingView()
                    } else if let home = viewModel.home {
                        greeting(home.hero)
                        heroCard(home.hero)
                        summarySection(home.summaryCards)
                        quickActionsSection(home.quickActions)
                    } else if !viewModel.errorMessage.isEmpty {
                        errorView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                viewModel.loadHome()
            }

            if showsBottomBar {
                CustomBottomBar(selectedTab: $selectedTab) { tab in
                    if tab == .category {
                        showingCategory = true
                    }
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showingCategory) {
            CategoryView()
        }
        .navigationDestination(isPresented: $showingCart) {
            CartView()
        }
        .navigationDestination(isPresented: $showingOrders) {
            OrdersView()
        }
        .task {
            viewModel.loadHome(forceReload: true)
        }
    }

    private var header: some View {
        HStack {
            Image(AppImages.bataLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 30)

            Spacer()

            Button { } label: {
                Image(systemName: "bell")
                    .font(.system(size: 19))
                    .foregroundStyle(AppColors.title)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)

            Text("AT")
                .montserrat(11, weight: .semibold)
                .foregroundStyle(AppColors.title)
                .frame(width: 34, height: 34)
                .background(AppColors.surface)
                .clipShape(Circle())
        }
    }

    private func greeting(_ hero: HomeHero) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Welcome back,")
                .montserrat(12)
                .foregroundStyle(AppColors.subtitle)
            Text(greetingName(from: hero.title))
                .montserrat(17, weight: .bold)
                .foregroundStyle(AppColors.title)
        }
        .padding(.top, 19)
        .padding(.bottom, 15)
    }

    private func heroCard(_ hero: HomeHero) -> some View {
        let product = hero.featuredProduct
        let offer = hero.featuredOffer
        let imageURL = product?.media?.images.first?.url

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
                if let imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFit()
                    } placeholder: {
                        Image(systemName: "bag.fill")
                            .foregroundStyle(AppColors.subtitle)
                    }
                    .padding(7)
                } else {
                    Image(systemName: "bag.fill")
                        .foregroundStyle(AppColors.subtitle)
                }
            }
            .frame(width: 80, height: 80)

            VStack(alignment: .leading, spacing: 4) {
                if let offer {
                    Text("\(offer.title.uppercased()) · \(discountText(offer))")
                        .montserrat(9, weight: .bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.white.opacity(0.20))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text(product?.title ?? hero.title)
                    .montserrat(14, weight: .bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                if let price = product?.pricing?.offerPrice ?? product?.pricing?.retailPrice {
                    Text("From Rs \(price.cleanValue) · Shop now →")
                        .montserrat(10)
                        .foregroundStyle(.white.opacity(0.90))
                } else {
                    Text(hero.subtitle)
                        .montserrat(10)
                        .foregroundStyle(.white.opacity(0.90))
                }
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 106)
        .background(
            LinearGradient(colors: [AppColors.primary, Color(red: 0.48, green: 0.01, blue: 0.04)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func summarySection(_ cards: [SummaryCard]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(cards) { card in
                VStack(alignment: .leading, spacing: 7) {
                    Image(systemName: card.key == "pending_payments" ? "clock" : "list.clipboard")
                        .font(.system(size: 17))
                        .foregroundStyle(AppColors.primary)
                    Text(card.label)
                        .montserrat(12)
                        .foregroundStyle(AppColors.subtitle)
                    Text("\(card.value)")
                        .montserrat(17, weight: .bold)
                        .foregroundStyle(AppColors.title)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .frame(height: 90)
                .background(AppColors.background)
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1) }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 16)
    }

    private func quickActionsSection(_ actions: [QuickAction]) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("Quick Actions")
                .montserrat(15, weight: .bold)
                .foregroundStyle(AppColors.title)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(actions) { action in
                    QuickActionCard(action: action) {
                        if action.key == "cart" {
                            showingCart = true
                        } else if action.key == "orders" {
                            showingOrders = true
                        }
                    }
                }
            }
        }
        .padding(.top, 17)
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28))
                .foregroundStyle(AppColors.primary)
            Text(viewModel.errorMessage)
                .montserrat(13)
                .foregroundStyle(AppColors.subtitle)
                .multilineTextAlignment(.center)
            Button("Try Again") { viewModel.loadHome() }
                .montserrat(13, weight: .semibold)
                .foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }


    private func greetingName(from title: String) -> String {
        title.replacingOccurrences(of: "Welcome back,", with: "", options: .caseInsensitive).trimmingCharacters(in: .whitespaces)
    }

    private func discountText(_ offer: FeaturedOffer) -> String {
        offer.discountType == "percentage" ? "\(offer.discountValue.cleanValue)% OFF" : "Rs \(offer.discountValue.cleanValue) OFF"
    }

}

private struct QuickActionCard: View {
    let action: QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
            Image(imageName)
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [.clear, .black.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: iconName)
                        .font(.system(size: 17))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 34, height: 34)
                        .background(.white.opacity(0.92))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Spacer()
                    if !action.badge.isEmpty {
                        Text(action.badge)
                            .montserrat(10, weight: .bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(AppColors.primary)
                            .clipShape(Capsule())
                    }
                }
                Spacer()
                Text(action.label)
                    .montserrat(13, weight: .bold)
                    .foregroundStyle(.white)
                Text(action.subtitle)
                    .montserrat(10)
                    .foregroundStyle(.white.opacity(0.90))
            }
            .padding(11)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var iconName: String {
        switch action.key {
        case "cart": "cart"
        case "recent_payments": "creditcard"
        case "orders": "list.clipboard"
        case "track": "truck.box"
        default: "square.grid.2x2"
        }
    }

    private var imageName: String {
        switch action.key {
        case "cart": AppImages.cart
        case "recent_payments": AppImages.payment
        case "orders": AppImages.order
        case "track": AppImages.track
        default: AppImages.order
        }
    }
}

private struct HomeLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SkeletonBlock(width: 120, height: 30)
                Spacer()
                SkeletonBlock(width: 34, height: 34, cornerRadius: 17)
                SkeletonBlock(width: 34, height: 34, cornerRadius: 17)
            }
            .padding(.bottom, 10)

            SkeletonBlock(width: 105, height: 13)
            SkeletonBlock(width: 145, height: 19)
            SkeletonBlock(width: nil, height: 106, cornerRadius: 15)

            HStack(spacing: 10) {
                SkeletonBlock(width: nil, height: 90, cornerRadius: 12)
                SkeletonBlock(width: nil, height: 90, cornerRadius: 12)
            }

            SkeletonBlock(width: 125, height: 18)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<4, id: \.self) { _ in
                    SkeletonBlock(width: nil, height: 140, cornerRadius: 14)
                }
            }
        }
        .padding(.top, 18)
    }
}

private extension Double {
    var cleanValue: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.2f", self)
    }
}

#Preview {
    HomeView()
}
