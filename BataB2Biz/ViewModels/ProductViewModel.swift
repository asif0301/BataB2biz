//
//  ProductViewModel.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class ProductViewModel {
    private let networkManager: NetworkManager
    let categoryCode: String
    let subCategoryCode: String
    let initialBrandCode: String?
    var products: [OfferProduct] = []
    var quickPills: [CatalogQuickPill] = []
    var categories: [CatalogFilterOption] = []
    var subCategories: [CatalogFilterOption] = []
    var brands: [CatalogFilterOption] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage = ""
    var currentPage = 1
    var lastPage = 1
    var selectedPill = "all"
    var searchText = ""
    var sortAscending = false
    var activeBrand: String?
    var activeCategoryCode: String
    var activeSubCategory: String?
    var activePriceMin: Int?
    var activePriceMax: Int?
    private var searchTask: Task<Void, Never>?
    var dataBounds = CatalogPriceRangeBounds(minPrice: 0, maxPrice: 6779)

    init(categoryCode: String = "all", subCategoryCode: String = "all", brandCode: String? = nil, networkManager: NetworkManager = .shared) {
        self.categoryCode = categoryCode
        self.subCategoryCode = subCategoryCode
        self.initialBrandCode = brandCode
        self.networkManager = networkManager
        self.activeBrand = brandCode
        self.activeCategoryCode = categoryCode
        self.activeSubCategory = subCategoryCode.lowercased() == "all" ? nil : subCategoryCode
        self.selectedPill = brandCode ?? (subCategoryCode.lowercased() == "all" ? "all" : subCategoryCode)
    }

    func loadProducts(reset: Bool = true) {
        if reset {
            guard !isLoading else { return }
            currentPage = 1
            products = []
            isLoading = true
        } else {
            guard !isLoadingMore, currentPage < lastPage else { return }
            currentPage += 1
            isLoadingMore = true
        }
        errorMessage = ""
        let page = currentPage
        Task { [weak self] in
            guard let self else { return }
            do {
                let quickPill = quickPills.first(where: { $0.value.lowercased() == selectedPill.lowercased() })
                let effectiveCategory = activeBrand?.isEmpty == false
                    ? "all"
                    : (quickPill == nil || selectedPill == "all" ? activeCategoryCode : selectedPill)
                var query: [URLQueryItem] = [
                    URLQueryItem(name: "category_code", value: effectiveCategory),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "order", value: sortAscending ? "asc" : "desc")
                ]
                let effectiveSubCategory = activeBrand?.isEmpty == false ? nil : activeSubCategory
                if let effectiveSubCategory, !effectiveSubCategory.isEmpty, effectiveSubCategory != "all" {
                    query.append(URLQueryItem(name: "sub_cat", value: effectiveSubCategory.lowercased()))
                }
                if let activeBrand, !activeBrand.isEmpty {
                    query.append(URLQueryItem(name: "brand_code", value: activeBrand.lowercased()))
                }
                if let activePriceMin {
                    query.append(URLQueryItem(name: "price_min", value: String(activePriceMin)))
                }
                if let activePriceMax {
                    query.append(URLQueryItem(name: "price_max", value: String(activePriceMax)))
                }
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    query.append(URLQueryItem(name: "search", value: searchText.trimmingCharacters(in: .whitespacesAndNewlines)))
                }
                let response: CatalogProductsResponse = try await networkManager.get(
                    APIService.Endpoint.products,
                    queryItems: query,
                    accessToken: UserDefaults.standard.string(forKey: "bata.authToken")
                )
                if reset {
                    products = response.data.products.items
                } else {
                    products.append(contentsOf: response.data.products.items)
                }
                quickPills = response.data.filtersData?.quickPills ?? quickPills
                categories = response.data.filtersData?.categories ?? categories
                subCategories = response.data.filtersData?.subCategories ?? subCategories
                brands = response.data.filtersData?.brands ?? brands
                if let bounds = response.data.filtersData?.priceRangeBounds {
                    dataBounds = bounds
                }
                lastPage = response.data.products.meta.lastPage
            } catch {
                if reset { errorMessage = error.localizedDescription }
            }
            isLoading = false
            isLoadingMore = false
        }
    }

    func selectPill(_ pill: CatalogQuickPill) {
        selectedPill = pill.value
        activeBrand = nil
        activeSubCategory = nil
        activeCategoryCode = pill.value == "all" ? "all" : pill.value
        loadProducts()
    }

    func toggleSort() {
        sortAscending.toggle()
        loadProducts()
    }

    func searchChanged() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled else { return }
            self?.loadProducts()
        }
    }

    func applyFilter(categoryCode: String? = nil, brand: String?, subCategory: String?, minimumPrice: Int?, maximumPrice: Int?) {
        if let categoryCode, !categoryCode.isEmpty {
            activeCategoryCode = categoryCode
        }
        activeBrand = brand
        activeSubCategory = subCategory
        activePriceMin = minimumPrice
        activePriceMax = maximumPrice
        if let subCategory, !subCategory.isEmpty {
            selectedPill = subCategory
        } else if let brand, !brand.isEmpty {
            selectedPill = brand
        } else {
            selectedPill = "all"
        }
        loadProducts()
    }
}
