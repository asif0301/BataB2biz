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
    var isLoading = false
    var isLoadingMore = false
    var errorMessage = ""
    var currentPage = 1
    var lastPage = 1
    var selectedPill = "all"
    var searchText = ""
    var sortAscending = false

    init(categoryCode: String = "all", subCategoryCode: String = "all", networkManager: NetworkManager = .shared) {
        self.categoryCode = categoryCode
        self.subCategoryCode = subCategoryCode
        self.networkManager = networkManager
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
                var query: [URLQueryItem] = [
                    URLQueryItem(name: "category_code", value: categoryCode),
                    URLQueryItem(name: "sub_cat", value: selectedPill == "all" ? subCategoryCode : selectedPill),
                    URLQueryItem(name: "page", value: String(page)),
                    URLQueryItem(name: "order", value: sortAscending ? "asc" : "desc")
                ]
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
}
