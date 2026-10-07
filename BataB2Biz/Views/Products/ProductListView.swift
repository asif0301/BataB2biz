import SwiftUI

struct ProductListView: View {
    let title: String
    let categoryCode: String
    let subCategoryCode: String
    @State private var viewModel: ProductViewModel
    @State private var favouriteIDs = Set<Int>()
    @Environment(\.dismiss) private var dismiss

    init(title: String = "Products", categoryCode: String = "all", subCategoryCode: String = "all") {
        self.title = title
        self.categoryCode = categoryCode
        self.subCategoryCode = subCategoryCode
        _viewModel = State(initialValue: ProductViewModel(categoryCode: categoryCode, subCategoryCode: subCategoryCode))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    controls
                    pills
                    if viewModel.isLoading && viewModel.products.isEmpty {
                        ProductListLoadingView()
                    } else if !viewModel.products.isEmpty {
                        productGrid
                    } else if !viewModel.errorMessage.isEmpty {
                        errorView
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .refreshable { viewModel.loadProducts() }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task { viewModel.loadProducts() }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 25, weight: .medium))
                    .foregroundStyle(AppColors.title)
            }
            .buttonStyle(.plain)
            Text(title.uppercased())
                .montserrat(20, weight: .bold)
                .foregroundStyle(AppColors.title)
                .lineLimit(1)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.subtitle)
        }
        .padding(.bottom, 24)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColors.subtitle)
                TextField("Search Article / brand", text: $viewModel.searchText)
                    .montserrat(15)
                    .submitLabel(.search)
                    .onSubmit { viewModel.loadProducts() }
            }
            .padding(.horizontal, 14)
            .frame(height: 58)
            .overlay { RoundedRectangle(cornerRadius: 17).stroke(AppColors.border, lineWidth: 1) }

            Button { viewModel.toggleSort() } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 38)
            }
            .buttonStyle(.plain)

            Button { } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 58, height: 58)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 17))
            }
            .buttonStyle(.plain)
        }
    }

    private var pills: some View {
        let values = viewModel.quickPills.isEmpty
            ? [CatalogQuickPill(label: "All", value: "all"), CatalogQuickPill(label: "New", value: "new"), CatalogQuickPill(label: "Best Seller", value: "bestseller"), CatalogQuickPill(label: "NOOS", value: "noos")]
            : viewModel.quickPills
        return ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(values) { pill in
                    Button { viewModel.selectPill(pill) } label: {
                        Text(pill.label)
                            .montserrat(14, weight: viewModel.selectedPill == pill.value ? .semibold : .regular)
                            .foregroundStyle(viewModel.selectedPill == pill.value ? .white : AppColors.title)
                            .padding(.horizontal, 22)
                            .frame(height: 54)
                            .background(viewModel.selectedPill == pill.value ? AppColors.primary : AppColors.surface)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.vertical, 18)
    }

    private var productGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(viewModel.products) { product in
                CatalogProductCard(product: product, isFavourite: favouriteIDs.contains(product.id) || product.isFavourite == true) {
                    if favouriteIDs.contains(product.id) { favouriteIDs.remove(product.id) } else { favouriteIDs.insert(product.id) }
                }
                .onAppear {
                    if product.id == viewModel.products.last?.id { viewModel.loadProducts(reset: false) }
                }
            }
            if viewModel.isLoadingMore {
                ProgressView().gridCellColumns(2).padding()
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark").font(.system(size: 28)).foregroundStyle(AppColors.primary)
            Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle).multilineTextAlignment(.center)
            Button("Try Again") { viewModel.loadProducts() }.montserrat(13, weight: .semibold).foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 100)
    }
}

private struct CatalogProductCard: View {
    let product: OfferProduct
    let isFavourite: Bool
    let onFavourite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .top) {
                if let badge = product.badges?.statusBadge ?? product.badges?.discountTag {
                    Text(badge).montserrat(11, weight: .bold).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 7)
                        .background(badge == "NOOS" ? Color.purple : Color.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
                Spacer()
                Button(action: onFavourite) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 25)).foregroundStyle(isFavourite ? AppColors.primary : AppColors.subtitle)
                }
                .buttonStyle(.plain)
            }
            productImage.frame(maxWidth: .infinity).frame(height: 160)
            if let discount = product.discount?.discountValue, discount > 0 {
                Text("-\(discount.cleanValue)%")
                    .montserrat(16, weight: .bold).foregroundStyle(.white)
                    .padding(.horizontal, 11).padding(.vertical, 8)
                    .background(AppColors.primary).clipShape(RoundedRectangle(cornerRadius: 7))
            }
            Text("Article \(product.article ?? "")").montserrat(16, weight: .bold).foregroundStyle(AppColors.title).lineLimit(1)
            Text("Brand \(product.brand ?? "")").montserrat(14).foregroundStyle(AppColors.subtitle).lineLimit(1)
            categoryTags
            if let retail = product.pricing.retailPrice {
                Text("Rs \(retail.cleanValue)").montserrat(12).foregroundStyle(AppColors.subtitle).strikethrough()
            }
            if let price = product.pricing.offerPrice ?? product.pricing.channelDiscountedPrice {
                Text("Rs \(price.cleanValue)").montserrat(17, weight: .bold).foregroundStyle(AppColors.primary)
            }
        }
        .padding(11).frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.background)
        .overlay { RoundedRectangle(cornerRadius: 17).stroke(AppColors.border, lineWidth: 1) }
        .clipShape(RoundedRectangle(cornerRadius: 17))
    }

    private var productImage: some View {
        Group {
            if let image = product.media?.images.first, let url = URL(string: image.url) {
                AsyncImage(url: url) { image in image.resizable().scaledToFit() } placeholder: { placeholder }
            } else { placeholder }
        }
    }

    private var placeholder: some View { Image(systemName: "photo").font(.system(size: 44)).foregroundStyle(Color.gray.opacity(0.45)) }

    private var categoryTags: some View {
        HStack(spacing: 4) {
            if let category = product.categories?.category?.name { tag(category) }
            if let sub = product.categories?.subCategory?.name { tag(sub) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func tag(_ text: String) -> some View {
        Text(text).montserrat(9).foregroundStyle(AppColors.primary).padding(.horizontal, 5).padding(.vertical, 3)
            .overlay { RoundedRectangle(cornerRadius: 4).stroke(AppColors.primary, style: StrokeStyle(lineWidth: 1, dash: [4, 3])) }
            .lineLimit(1)
    }
}

private struct ProductListLoadingView: View {
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(0..<6, id: \.self) { _ in SkeletonBlock(width: nil, height: 390, cornerRadius: 17) }
        }
    }
}

private extension Double {
    var cleanValue: String { truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.1f", self) }
}

#Preview { ProductListView(title: "Men Dress Shoes") }
