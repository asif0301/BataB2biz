import SwiftUI

struct ProductDetailView: View {
    let productID: Int
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProductDetailViewModel
    @State private var selectedImage = 0
    @State private var packQuantity = 1
    @State private var isFavourite = false
    @State private var showingCart = false

    init(productID: Int) {
        self.productID = productID
        _viewModel = State(initialValue: ProductDetailViewModel(productID: productID))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.data == nil {
                DetailLoadingView()
            } else if let data = viewModel.data {
                detailContent(data)
            } else if !viewModel.errorMessage.isEmpty {
                errorView
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .overlay(alignment: .top) {
            if !viewModel.cartMessage.isEmpty || !viewModel.cartErrorMessage.isEmpty {
                Text(viewModel.cartMessage.isEmpty ? viewModel.cartErrorMessage : viewModel.cartMessage)
                    .montserrat(13, weight: .semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(viewModel.cartMessage.isEmpty ? Color.red : Color.green)
                    .clipShape(Capsule())
                    .padding(.top, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showingCart) { CartView() }
        .task { viewModel.load() }
    }

    private func detailContent(_ data: ProductDetailData) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    header
                    if let discount = data.product.discount?.discountValue, discount > 0 {
                        Text("-\(discount.cleanValue)%")
                            .montserrat(12, weight: .bold).foregroundStyle(.white)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(AppColors.primary).clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    gallery(data.product)
                    productSummary(data.product)
                    detailsCard(data.product)
                    assortment(data.product, packs: data.packCodes, isAvailable: isAvailable(data.product))
                    if isAvailable(data.product) { sizesSection(data.packCodes) }
                    similarProducts(data.similar)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
            }
            .scrollIndicators(.hidden)
            bottomBar(data.product, packs: data.packCodes)
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left").font(.system(size: 20, weight: .medium)).foregroundStyle(AppColors.title)
            }
            .buttonStyle(.plain)
            Text("Product Details").montserrat(17, weight: .bold).foregroundStyle(AppColors.title)
            Spacer()
            Image(systemName: "bell").font(.system(size: 19)).foregroundStyle(AppColors.subtitle)
        }
        .padding(.top, 14).padding(.bottom, 18)
    }

    private func gallery(_ product: OfferProduct) -> some View {
        let images = product.media?.images ?? []
        return VStack(spacing: 12) {
            Group {
                if let image = images[safe: selectedImage], let url = URL(string: image.url) {
                    AsyncImage(url: url) { image in image.resizable().scaledToFit() } placeholder: { detailPlaceholder }
                } else { detailPlaceholder }
            }
            .frame(maxWidth: .infinity).frame(height: 275)

            if !images.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            AsyncImage(url: URL(string: image.url)) { image in image.resizable().scaledToFit() } placeholder: { detailPlaceholder }
                                .frame(width: 74, height: 74)
                                .background(AppColors.background)
                                .overlay { RoundedRectangle(cornerRadius: 8).stroke(index == selectedImage ? AppColors.primary : AppColors.border, lineWidth: index == selectedImage ? 2 : 1) }
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture { selectedImage = index }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func productSummary(_ product: OfferProduct) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center) {
                Text("Article \(product.article ?? "")").montserrat(17, weight: .bold).foregroundStyle(AppColors.title)
                Spacer()
                if !isAvailable(product) {
                    Text("Out of Stock").montserrat(13, weight: .semibold).foregroundStyle(.white).padding(.horizontal, 14).padding(.vertical, 10).background(Color.orange).clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            HStack(spacing: 5) {
                detailTag(product.categories?.category?.name ?? "")
                detailTag(product.categories?.subCategory?.name ?? "")
            }
            if let retail = product.pricing.retailPrice, let offer = product.pricing.offerPrice, retail != offer {
                HStack(spacing: 8) {
                    Text("Rs \(retail.cleanValue)").montserrat(14).foregroundStyle(AppColors.subtitle).strikethrough()
                    Text("Rs \(offer.cleanValue)").montserrat(18, weight: .bold).foregroundStyle(AppColors.primary)
                }
                .padding(.top, 3)
            } else if let price = product.pricing.offerPrice ?? product.pricing.retailPrice {
                Text("Rs \(price.cleanValue)").montserrat(18, weight: .bold).foregroundStyle(AppColors.primary).padding(.top, 3)
            }
        }
        .padding(.top, 10)
    }

    private func detailsCard(_ product: OfferProduct) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PRODUCT DETAILS").montserrat(10, weight: .bold).foregroundStyle(AppColors.subtitle)
            HStack {
                detailLine("Article", product.article ?? "")
                detailLine("Brand", product.brand ?? "")
            }
            HStack {
                detailLine("Category", product.categories?.category?.code ?? "")
                detailLine("Sub-Category", product.categories?.subCategory?.code ?? "")
            }
        }
        .padding(13).frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface).clipShape(RoundedRectangle(cornerRadius: 10)).padding(.top, 14)
    }

    private func assortment(_ product: OfferProduct, packs: [PackCode], isAvailable: Bool) -> some View {
        let pack = packs.first
        let pairs = pack?.pairsPerPack ?? 0
        let totalPairs = pairs * packQuantity
        let totalPacks = packQuantity
        return VStack(alignment: .leading, spacing: 0) {
            Text("Assortment Order").montserrat(13, weight: .bold).foregroundStyle(AppColors.title).padding(.vertical, 12)
            HStack {
                Text("Pack Code").montserrat(12).foregroundStyle(AppColors.subtitle)
                Text(isAvailable ? (pack?.code ?? product.code ?? "A") : "N/A").montserrat(12, weight: .bold)
                Spacer()
                Text("Pairs Per Pack").montserrat(12).foregroundStyle(AppColors.subtitle)
                Text(isAvailable ? "\(pairs)" : "N/A").montserrat(12, weight: .bold)
            }
            .padding(12).overlay(alignment: .top) { Rectangle().fill(AppColors.border).frame(height: 1) }
            HStack {
                Text("Quantity (Packs)").montserrat(12, weight: .bold)
                Spacer()
                quantityButton("minus", enabled: isAvailable && packQuantity > 1) { packQuantity -= 1 }
                Text(isAvailable ? "\(packQuantity)" : "N/A").montserrat(12, weight: .bold).frame(width: 28)
                quantityButton("plus", enabled: isAvailable) { packQuantity += 1 }
            }
            .padding(12).overlay(alignment: .top) { Rectangle().fill(AppColors.border).frame(height: 1) }
            HStack {
                Text("Total Packs").montserrat(12).foregroundStyle(AppColors.subtitle)
                Text(isAvailable ? "\(totalPacks)" : "N/A").montserrat(12, weight: .bold)
                Spacer()
                Text("Total Pairs").montserrat(12).foregroundStyle(AppColors.subtitle)
                Text(isAvailable ? "\(totalPairs)" : "N/A").montserrat(12, weight: .bold)
            }
            .padding(12).overlay(alignment: .top) { Rectangle().fill(AppColors.border).frame(height: 1) }
        }
        .background(AppColors.background).overlay { RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1) }
        .clipShape(RoundedRectangle(cornerRadius: 10)).padding(.top, 12)
    }

    private func sizesSection(_ packs: [PackCode]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sizes").montserrat(16, weight: .bold).foregroundStyle(AppColors.title)
            ForEach(packs) { pack in
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(pack.types, id: \.type) { type in
                        Text(type.type).montserrat(16, weight: .bold).foregroundStyle(AppColors.primary)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                            ForEach(type.sizes) { size in
                                Text("Size \(size.size) · \(size.quantity)")
                                    .montserrat(13, weight: .semibold)
                                    .foregroundStyle(AppColors.title)
                                    .padding(.horizontal, 10)
                                    .frame(minHeight: 42)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.surface)
                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                            }
                        }
                    }
                }
                .padding(14)
                .background(AppColors.background)
                .overlay { RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1) }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 24)
    }

    private func similarProducts(_ products: [OfferProduct]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text("Similar Products").montserrat(15, weight: .bold).foregroundStyle(AppColors.title)
                Spacer(); Text("View all").montserrat(12).foregroundStyle(AppColors.primary)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(products) { product in SimilarProductCard(product: product) }
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 16)
    }

    private func bottomBar(_ product: OfferProduct, packs: [PackCode]) -> some View {
        let price = product.pricing.offerPrice ?? product.pricing.retailPrice ?? 0
        let pairs = Double(packs.first?.pairsPerPack ?? 1)
        let total = price * pairs * Double(packQuantity)
        let available = isAvailable(product)
        return VStack(spacing: 10) {
            HStack {
                Text("Total").montserrat(15, weight: .bold)
                Spacer()
                Text(available ? "Rs \(total.formatted(.number.precision(.fractionLength(0...1))))" : "N/A")
                    .montserrat(16, weight: .bold).foregroundStyle(AppColors.primary)
            }
            HStack(spacing: 12) {
                Button { isFavourite.toggle() } label: {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .font(.system(size: 20)).foregroundStyle(AppColors.primary)
                        .frame(width: 58, height: 52).overlay { RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1) }
                }
                .buttonStyle(.plain)
                Button { showingCart = true } label: {
                    Image(systemName: "cart").font(.system(size: 21)).foregroundStyle(AppColors.primary)
                        .frame(width: 58, height: 52).overlay { RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1) }
                }
                .buttonStyle(.plain)
                Button {
                    Task { await viewModel.addToCart(packQuantity: packQuantity) }
                } label: {
                    Group {
                        if viewModel.isAddingToCart {
                            ProgressView().tint(.white)
                        } else {
                            Text("Add to Cart").montserrat(15, weight: .bold)
                        }
                    }
                    .foregroundStyle(available ? .white : AppColors.subtitle)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(available ? AppColors.primary : Color.gray.opacity(0.22))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!available || viewModel.isAddingToCart)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 10).background(AppColors.background)
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle).multilineTextAlignment(.center)
            Button("Try Again") { viewModel.load() }.foregroundStyle(AppColors.primary)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var detailPlaceholder: some View { Image(systemName: "photo").font(.system(size: 44)).foregroundStyle(Color.gray.opacity(0.45)) }
    private func isAvailable(_ product: OfferProduct) -> Bool { !(product.packCodeID?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) }
    private func detailTag(_ value: String) -> some View { Text(value).montserrat(10).foregroundStyle(AppColors.primary).padding(.horizontal, 7).padding(.vertical, 4).overlay { RoundedRectangle(cornerRadius: 4).stroke(AppColors.primary, style: StrokeStyle(lineWidth: 1, dash: [4, 3])) } }
    private func detailLine(_ label: String, _ value: String) -> some View { HStack(spacing: 3) { Text("\(label):").montserrat(11).foregroundStyle(AppColors.subtitle); Text(value).montserrat(11, weight: .semibold).foregroundStyle(AppColors.title) }.frame(maxWidth: .infinity, alignment: .leading) }
    private func quantityButton(_ icon: String, enabled: Bool, action: @escaping () -> Void) -> some View { Button(action: action) { Image(systemName: icon).font(.system(size: 12, weight: .bold)).foregroundStyle(enabled ? AppColors.primary : AppColors.subtitle).frame(width: 24, height: 24).background(enabled ? AppColors.primary.opacity(0.1) : AppColors.surface).clipShape(RoundedRectangle(cornerRadius: 6)) }.buttonStyle(.plain).disabled(!enabled) }
}

private struct SimilarProductCard: View {
    let product: OfferProduct
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group { if let url = product.media?.images.first.flatMap({ URL(string: $0.url) }) { AsyncImage(url: url) { $0.resizable().scaledToFit() } placeholder: { Image(systemName: "photo") } } else { Image(systemName: "photo") } }
                .frame(width: 150, height: 105).background(AppColors.surface)
            Text(product.title).montserrat(12, weight: .bold).lineLimit(2)
            Text("Article \(product.article ?? "")").montserrat(10).foregroundStyle(AppColors.subtitle)
            Text("Rs \((product.pricing.offerPrice ?? product.pricing.retailPrice ?? 0).cleanValue)").montserrat(13, weight: .bold).foregroundStyle(AppColors.primary)
        }
        .padding(8).frame(width: 166, alignment: .leading).background(AppColors.background).overlay { RoundedRectangle(cornerRadius: 10).stroke(AppColors.border, lineWidth: 1) }.clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct DetailLoadingView: View {
    var body: some View { ScrollView { VStack(spacing: 14) { SkeletonBlock(width: nil, height: 28); SkeletonBlock(width: nil, height: 300); SkeletonBlock(width: nil, height: 90); SkeletonBlock(width: nil, height: 100); SkeletonBlock(width: nil, height: 160) }.padding(20) } }
}

private extension Collection {
    subscript(safe index: Index) -> Element? { indices.contains(index) ? self[index] : nil }
}

private extension Double {
    var cleanValue: String { truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(format: "%.1f", self) }
}

#Preview { ProductDetailView(productID: 1849) }
