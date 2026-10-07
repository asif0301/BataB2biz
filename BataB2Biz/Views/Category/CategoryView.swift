//
//  CategoryView.swift
//  BataB2Biz
//

import SwiftUI

struct CategoryView: View {
    var showsBottomBar = false
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CategoryViewModel()
    @State private var searchText = ""
    @State private var selectedCategoryCode = "all"
    @State private var selectedTab = AppTab.category
//    @State private var selectedSubCategory: SubCategory?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        header
                        searchField
                        parentCategoryChips

                        if viewModel.isLoading && viewModel.overview == nil {

                            CategoryLoadingView()

                        } else if let overview = viewModel.overview {

                            categoryGrid(overview.subCategories)
                            brandsSection(overview.topBrands)

                        } else if !viewModel.errorMessage.isEmpty {

                            errorView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
                .refreshable {
                    viewModel.load(
                        categoryCode: selectedCategoryCode,
                        search: searchText
                    )
                }

                if showsBottomBar {
                    CustomBottomBar(selectedTab: $selectedTab) { tab in
                        if tab == .home {
                            dismiss()
                        }
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SubCategory.self) { category in
                ProductListView(
                    title: category.name ?? "Products",
                    categoryCode: category.categoryCode,
                    subCategoryCode: category.subCategoryCode
                )
            }
            .task {
                viewModel.load()
            }
        }
    }

//    var body: some View {
//        VStack(spacing: 0) {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 0) {
//                    header
//                    searchField
//                    parentCategoryChips
//
//                    if viewModel.isLoading && viewModel.overview == nil {
//                        CategoryLoadingView()
//                    } else if let overview = viewModel.overview {
//                        categoryGrid(overview.subCategories)
//                        brandsSection(overview.topBrands)
//                    } else if !viewModel.errorMessage.isEmpty {
//                        errorView
//                    }
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 15)
//                .padding(.bottom, 20)
//            }
//            .scrollIndicators(.hidden)
//            .refreshable {
//                viewModel.load(categoryCode: selectedCategoryCode, search: searchText)
//            }
//
//            if showsBottomBar {
//                CustomBottomBar(selectedTab: $selectedTab) { tab in
//                    if tab == .home {
//                        dismiss()
//                    }
//                }
//            }
//        }
//        .background(AppColors.background.ignoresSafeArea())
//        .navigationBarBackButtonHidden(true)
//        .toolbar(.hidden, for: .navigationBar)
//        .navigationDestination(item: $selectedSubCategory) { category in
//            ProductListView(
//                title: category.name ?? "Products",
//                categoryCode: category.categoryCode,
//                subCategoryCode: category.subCategoryCode
//            )
//        }
//        .task {
//            viewModel.load()
//        }
//    }

    private var header: some View {
        HStack {
            Text("Shop by Category")
                .montserrat(17, weight: .bold)
                .foregroundStyle(AppColors.title)
            Spacer()
            Button { } label: {
                Image(systemName: "bell")
                    .font(.system(size: 19))
                    .foregroundStyle(AppColors.title)
            }
            .buttonStyle(.plain)
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.subtitle)
            TextField("Search categories...", text: $searchText)
                .montserrat(14)
                .submitLabel(.search)
                .onSubmit {
                    viewModel.load(categoryCode: selectedCategoryCode, search: searchText)
                }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(AppColors.background)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.border, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.top, 21)
    }

    private var parentCategoryChips: some View {
        let categories = viewModel.overview?.parentCategories ?? [ParentCategory(code: "all", name: "All")]

        return ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(categories) { category in
                    Button {
                        selectedCategoryCode = category.code
                        viewModel.load(categoryCode: category.code, search: searchText)
                    } label: {
                        Text(category.name.capitalized)
                            .montserrat(12, weight: selectedCategoryCode == category.code ? .semibold : .regular)
                            .foregroundStyle(selectedCategoryCode == category.code ? .white : AppColors.title)
                            .padding(.horizontal, 15)
                            .frame(height: 30)
                            .background(selectedCategoryCode == category.code ? AppColors.primary : AppColors.surface)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 17)
        .padding(.bottom, 18)
        .scrollIndicators(.hidden)
    }

    private func categoryGrid(_ categories: [SubCategory]) -> some View {
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(categories) { category in
                CategoryCard(category: category) {
                    navigationPath.append(category)
                }
            }
//            ForEach(categories) { category in
//                CategoryCard(category: category) { selectedSubCategory = category }
//            }
        }
    }

    private func brandsSection(_ brands: [TopBrand]) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("Top Brands")
                .montserrat(15, weight: .bold)
                .foregroundStyle(AppColors.title)
                .padding(.top, 17)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(brands) { brand in
                        Text(brand.name.capitalized)
                            .montserrat(12, weight: .semibold)
                            .foregroundStyle(AppColors.title)
                            .padding(.horizontal, 12)
                            .frame(height: 30)
                            .background(AppColors.background)
                            .overlay { RoundedRectangle(cornerRadius: 7).stroke(AppColors.border, lineWidth: 1) }
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Text(viewModel.errorMessage)
                .montserrat(13)
                .foregroundStyle(AppColors.subtitle)
                .multilineTextAlignment(.center)
            Button("Try Again") { viewModel.load(categoryCode: selectedCategoryCode, search: searchText) }
                .montserrat(13, weight: .semibold)
                .foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }

}

private struct CategoryLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(0..<12, id: \.self) { _ in
                    SkeletonBlock(width: nil, height: 92, cornerRadius: 11)
                }
            }
            .padding(.top, 3)

            SkeletonBlock(width: 100, height: 18)
                .padding(.top, 9)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonBlock(width: 78, height: 30, cornerRadius: 7)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct CategoryCard: View {
    let category: SubCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 7) {
                AsyncImage(url: URL(string: category.imageURL)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "shoeprints.fill")
                        .foregroundStyle(AppColors.subtitle)
                }
                .frame(width: 48, height: 48)
                .background(Color(red: 1, green: 0.95, blue: 0.95))
                .clipShape(Circle())

                Text(category.name?.capitalized ?? "Category")
                    .montserrat(10, weight: .medium)
                    .foregroundStyle(AppColors.title)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .padding(.vertical, 8)
            .background(AppColors.background)
            .overlay { RoundedRectangle(cornerRadius: 11).stroke(AppColors.border, lineWidth: 1) }
            .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryView()
}
