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
    var products: [OfferProduct] = []
    var quickPills: [CatalogQuickPill] = []
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
    var activePriceMin: Int?
    var activePriceMax: Int?
    private var searchTask: Task<Void, Never>?

    init(categoryCode: String = "all", subCategoryCode: String = "all", networkManager: NetworkManager = .shared) {
        self.categoryCode = categoryCode
        self.subCategoryCode = subCategoryCode
        self.networkManager = networkManager
        self.selectedPill = subCategoryCode.lowercased() == "all" ? "all" : subCategoryCode
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
                let effectiveCategory = activeBrand?.isEmpty == false || selectedPill == "all"
                    ? "all"
                    : (quickPill == nil ? categoryCode : selectedPill)
                var query: [URLQueryItem] = [
                    URLQueryItem(name: "category_code", value: effectiveCategory),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "order", value: sortAscending ? "asc" : "desc")
                ]
                let effectiveSubCategory = activeBrand?.isEmpty == false || selectedPill == "all"
                    ? nil
                    : (quickPill == nil ? selectedPill : (subCategoryCode == "all" ? nil : subCategoryCode))
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
                subCategories = response.data.filtersData?.subCategories ?? subCategories
                brands = response.data.filtersData?.brands ?? brands
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

    func applyFilter(brand: String?, subCategory: String?, minimumPrice: Int?, maximumPrice: Int?) {
        activeBrand = brand
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
