import SwiftUI

struct OffersView: View {
    var showsBottomBar = false
    @State private var viewModel = OffersViewModel()
    @State private var selectedTab = AppTab.offers
    @State private var favouriteIDs = Set<Int>()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if viewModel.isLoading && viewModel.data == nil {
                        OffersLoadingView()
                    } else if let data = viewModel.data {
                        offerBanners(data.offers)
                        productGrid(data.products)
                    } else if !viewModel.errorMessage.isEmpty {
                        errorView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .refreshable { viewModel.loadOffers(forceReload: true) }

            if showsBottomBar { CustomBottomBar(selectedTab: $selectedTab) }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { viewModel.loadOffers(forceReload: true) }
    }

    private var header: some View {
        HStack {
            Text("Offers")
                .montserrat(22, weight: .bold)
                .foregroundStyle(AppColors.title)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.subtitle)
                .frame(width: 34, height: 34)
        }
        .padding(.bottom, 22)
    }

    private func offerBanners(_ offers: [OfferSummary]) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 14) {
                ForEach(offers) { offer in
                    VStack(alignment: .leading, spacing: 7) {
                        Image(systemName: "gift")
                            .font(.system(size: 28, weight: .medium))
                        Text(offer.name).montserrat(22, weight: .bold)
                        Text(offerLine(offer)).montserrat(13)
                        Text(dateRange(offer)).montserrat(13)
                    }
                    .foregroundStyle(.white)
                    .padding(20)
                    .frame(width: 300, height: 150, alignment: .leading)
                    .background(LinearGradient(colors: [AppColors.primary, Color(red: 0.53, green: 0.01, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.bottom, 22)
    }

    private func productGrid(_ products: [OfferProduct]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(products) { product in
                OfferProductCard(product: product, isFavourite: favouriteIDs.contains(product.id) || product.isFavourite == true) {
                    if favouriteIDs.contains(product.id) { favouriteIDs.remove(product.id) } else { favouriteIDs.insert(product.id) }
                }
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 28)).foregroundStyle(AppColors.primary)
            Text(viewModel.errorMessage)
                .montserrat(13).foregroundStyle(AppColors.subtitle).multilineTextAlignment(.center)
            Button("Try Again") { viewModel.loadOffers(forceReload: true) }
                .montserrat(13, weight: .semibold).foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 100)
    }

    private func offerLine(_ offer: OfferSummary) -> String {
        offer.discountType == "percentage" ? "\(offer.discountValue.cleanValue)% off" : "Rs \(offer.discountValue.cleanValue) off"
    }

    private func dateRange(_ offer: OfferSummary) -> String {
        "\(shortDate(offer.startDate)) - \(shortDate(offer.endDate))"
    }

    private func shortDate(_ value: String) -> String {
        let input = DateFormatter(); input.dateFormat = "yyyy-MM-dd"
        let output = DateFormatter(); output.dateFormat = "d MMM yyyy"
        return input.date(from: value).map { output.string(from: $0) } ?? value
    }
}

private struct OfferProductCard: View {
    let product: OfferProduct
    let isFavourite: Bool
    let onFavourite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top) {
                Text(discountLabel)
                    .montserrat(11, weight: .bold).foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(Color.orange).clipShape(RoundedRectangle(cornerRadius: 7))
                Spacer()
                Button(action: onFavourite) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundStyle(isFavourite ? AppColors.primary : AppColors.subtitle)
                }
                .buttonStyle(.plain)
            }

            productImage.frame(maxWidth: .infinity).frame(height: 125)

            if let tag = product.discount?.discountValue, tag > 0 {
                Text("-\(tag.cleanValue)%")
                    .montserrat(15, weight: .bold).foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 7)
                    .background(AppColors.primary).clipShape(RoundedRectangle(cornerRadius: 7))
            }

            Text("Article \(product.article ?? "")")
                .montserrat(15, weight: .bold).foregroundStyle(AppColors.title).lineLimit(1)
            Text(product.article ?? product.title)
                .montserrat(13).foregroundStyle(AppColors.subtitle).lineLimit(1)
            categoryTags
            if let retailPrice = product.pricing.retailPrice {
                Text("Rs \(retailPrice.cleanValue)")
                    .montserrat(12).foregroundStyle(AppColors.subtitle).strikethrough()
            }
            if let offerPrice = product.pricing.offerPrice ?? product.pricing.channelDiscountedPrice {
                Text("Rs \(offerPrice.cleanValue)")
                    .montserrat(17, weight: .bold).foregroundStyle(AppColors.primary)
            }
        }
        .padding(11).frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.background)
        .overlay { RoundedRectangle(cornerRadius: 17).stroke(AppColors.border, lineWidth: 1) }
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    private var productImage: some View {
        Group {
            if let urlString = product.media?.images.first?.url, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in image.resizable().scaledToFit() } placeholder: {
                    Image(systemName: "photo").font(.system(size: 42)).foregroundStyle(Color.gray.opacity(0.45))
                }
            } else {
                Image(systemName: "photo").font(.system(size: 42)).foregroundStyle(Color.gray.opacity(0.45))
            }
        }
    }

    private var categoryTags: some View {
        HStack(spacing: 4) {
            if let category = product.categories?.category?.name { tag(category) }
            if let subCategory = product.categories?.subCategory?.name { tag(subCategory) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tag(_ value: String) -> some View {
        Text(value).montserrat(9).foregroundStyle(AppColors.primary)
            .padding(.horizontal, 5).padding(.vertical, 3)
            .overlay { RoundedRectangle(cornerRadius: 4).stroke(AppColors.primary, style: StrokeStyle(lineWidth: 1, dash: [4, 3])) }
            .lineLimit(1)
    }

    private var discountLabel: String { product.discount?.discountType == "fixed" ? "Fixed" : "Percentage" }
}

private struct OffersLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            SkeletonBlock(width: nil, height: 150, cornerRadius: 20)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(0..<6, id: \.self) { _ in SkeletonBlock(width: nil, height: 350, cornerRadius: 17) }
            }
        }
    }
}

private extension Double {
    var cleanValue: String { truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.2f", self) }
}

#Preview { OffersView() }
