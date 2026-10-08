import SwiftUI

struct ProductListView: View {
    let title: String
    let categoryCode: String
    let subCategoryCode: String
    let brandCode: String?
    @State private var viewModel: ProductViewModel
    @State private var favouriteIDs = Set<Int>()
    @State private var showingFilters = false
    @State private var selectedProductID: Int?
    @Environment(\.dismiss) private var dismiss

    init(title: String = "Products", categoryCode: String = "all", subCategoryCode: String = "all", brandCode: String? = nil) {
        self.title = title
        self.categoryCode = categoryCode
        self.subCategoryCode = subCategoryCode
        self.brandCode = brandCode
        _viewModel = State(initialValue: ProductViewModel(categoryCode: categoryCode, subCategoryCode: subCategoryCode, brandCode: brandCode))
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                header
                controls
                pills
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            if viewModel.isLoading && viewModel.products.isEmpty {
                ScrollView {
                    ProductListLoadingView()
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            } else if !viewModel.products.isEmpty {
                ScrollView {
                    productGrid
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
                .refreshable { viewModel.loadProducts() }
            } else if !viewModel.errorMessage.isEmpty {
                errorView
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingFilters) {
            ProductFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .navigationDestination(item: $selectedProductID) { productID in
            ProductDetailView(productID: productID)
        }
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
                    .onChange(of: viewModel.searchText) { _, _ in viewModel.searchChanged() }
                    .onSubmit { viewModel.loadProducts() }
            }
            .padding(.horizontal, 14)
            .frame(height: 45)
            .overlay { RoundedRectangle(cornerRadius: 17).stroke(AppColors.border, lineWidth: 1) }

            Button { viewModel.toggleSort() } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 38)
            }
            .buttonStyle(.plain)

            Button { showingFilters = true } label: {
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
                            .frame(height: 45)
                            .background(viewModel.selectedPill == pill.value ? AppColors.primary : AppColors.surface)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                if viewModel.initialBrandCode == nil {
                    ForEach(viewModel.subCategories) { category in
                        let isSelected = viewModel.selectedPill == category.code
                        Button {
                            viewModel.applyFilter(
                                brand: nil,
                                subCategory: isSelected ? nil : category.code,
                                minimumPrice: viewModel.activePriceMin,
                                maximumPrice: viewModel.activePriceMax
                            )
                        } label: {
                            Text(category.name?.capitalized ?? category.code)
                                .montserrat(12, weight: isSelected ? .semibold : .regular)
                                .foregroundStyle(isSelected ? .white : AppColors.title)
                                .padding(.horizontal, 16)
                                .frame(height: 45)
                                .background(isSelected ? AppColors.primary : AppColors.surface)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                ForEach(viewModel.brands) { brand in
                    let isSelected = viewModel.selectedPill == brand.code
                    Button {
                        viewModel.applyFilter(
                            brand: isSelected ? nil : brand.code,
                            subCategory: nil,
                            minimumPrice: viewModel.activePriceMin,
                            maximumPrice: viewModel.activePriceMax
                        )
                    } label: {
                        Text(brand.name?.capitalized ?? brand.code)
                            .montserrat(12, weight: isSelected ? .semibold : .regular)
                            .foregroundStyle(isSelected ? .white : AppColors.title)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(isSelected ? AppColors.primary : AppColors.surface)
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
                .onTapGesture { selectedProductID = product.id }
                .onAppear {
                    if product.id == viewModel.products.last?.id { viewModel.loadProducts(reset: false) }
                }
            }
            if viewModel.isLoadingMore {
                ProgressView().gridCellColumns(2).padding()
            }
        }
        .padding(.top, 4)
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

private struct ProductFilterSheet: View {
    let viewModel: ProductViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var category = "all"
    @State private var brand = ""
    @State private var subCategory = ""
    @State private var minimumPrice = 0.0
    @State private var maximumPrice = 0.0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Filter Products")
                    .montserrat(22, weight: .bold)
                    .foregroundStyle(AppColors.title)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                ScrollView {
                    categorySection
                    subCategorySection
                    brandSection
                    priceSection
                }

                HStack(spacing: 12) {
                    Button("Clear All") {
                        category = "all"
                        brand = ""
                        subCategory = ""
                        minimumPrice = bounds.minPrice
                        maximumPrice = bounds.maxPrice
                    }
                    .montserrat(15, weight: .bold)
                    .foregroundStyle(AppColors.primary)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .overlay { RoundedRectangle(cornerRadius: 14).stroke(AppColors.primary, lineWidth: 1) }

                    Button("Apply Filters") {
                        viewModel.applyFilter(
                            categoryCode: category,
                            brand: brand.isEmpty ? nil : brand,
                            subCategory: subCategory.isEmpty ? nil : subCategory,
                            minimumPrice: Int(minimumPrice) > Int(bounds.minPrice) ? Int(minimumPrice) : nil,
                            maximumPrice: Int(maximumPrice) < Int(bounds.maxPrice) ? Int(maximumPrice) : nil
                        )
                        dismiss()
                    }
                    .montserrat(15, weight: .bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .background(AppColors.background)
        }
        .onAppear {
            category = viewModel.activeCategoryCode
            subCategory = viewModel.activeSubCategory ?? ""
            brand = viewModel.activeBrand ?? ""
            minimumPrice = bounds.minPrice
            maximumPrice = bounds.maxPrice
        }
    }

    private var bounds: (minPrice: Double, maxPrice: Double) {
        let bounds = viewModel.dataBounds
        return (bounds.minPrice, max(bounds.maxPrice, bounds.minPrice + 1))
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Price Range").montserrat(21, weight: .bold).foregroundStyle(AppColors.title)
            Slider(value: $minimumPrice, in: bounds.minPrice...maximumPrice)
                .tint(AppColors.primary)
            Slider(value: $maximumPrice, in: minimumPrice...bounds.maxPrice)
                .tint(AppColors.primary)
            HStack {
                Text("Rs \(minimumPrice.cleanValue)")
                Spacer()
                Text("Rs \(maximumPrice.cleanValue)")
            }
            .montserrat(13)
            .foregroundStyle(AppColors.subtitle)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }

    private var categorySection: some View {
        FilterOptionsSection(title: "Category", options: viewModel.categories, selection: $category, emptyValue: "all") {
            subCategory = ""
        }
    }

    private var subCategorySection: some View {
        let selectedCategory = category.lowercased()
        let visibleOptions = viewModel.subCategories.filter { option in
            selectedCategory.isEmpty || selectedCategory == "all" || option.categoryCode?.lowercased() == selectedCategory
        }
        return FilterOptionsSection(title: "Sub Category", options: visibleOptions, selection: $subCategory, emptyValue: "")
    }

    private var brandSection: some View {
        FilterOptionsSection(title: "Brand", options: viewModel.brands, selection: $brand, emptyValue: "")
    }
}

private struct FilterOptionsSection: View {
    let title: String
    let options: [CatalogFilterOption]
    @Binding var selection: String
    let emptyValue: String
    let onSelectionChanged: () -> Void

    init(title: String, options: [CatalogFilterOption], selection: Binding<String>, emptyValue: String, onSelectionChanged: @escaping () -> Void = {}) {
        self.title = title
        self.options = options
        self._selection = selection
        self.emptyValue = emptyValue
        self.onSelectionChanged = onSelectionChanged
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .montserrat(21, weight: .bold)
                .foregroundStyle(AppColors.title)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 10) {
                FilterChip(title: "All", isSelected: selection == emptyValue) {
                    selection = emptyValue
                    onSelectionChanged()
                }
                ForEach(options) { option in
                    FilterChip(title: option.name ?? option.code, isSelected: selection == option.code) {
                        selection = option.code
                        onSelectionChanged()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title.uppercased())
                .montserrat(13)
                .foregroundStyle(isSelected ? .white : AppColors.subtitle)
                .padding(.horizontal, 15)
                .frame(minHeight: 42)
                .background(isSelected ? AppColors.primary : AppColors.background)
                .overlay { RoundedRectangle(cornerRadius: 22).stroke(isSelected ? AppColors.primary : AppColors.border, lineWidth: 1) }
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
