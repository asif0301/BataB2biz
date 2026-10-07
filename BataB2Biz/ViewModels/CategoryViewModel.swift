//
//  CategoryViewModel.swift
//  BataB2Biz
//

import Foundation
import Observation

@Observable
@MainActor
final class CategoryViewModel {
    private let networkManager: NetworkManager
    var overview: CategoryOverviewData?
    var isLoading = false
    var errorMessage = ""

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func load(categoryCode: String = "all", search: String = "") {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = ""

        var queryItems = [URLQueryItem(name: "category_code", value: categoryCode)]
        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                let response: CategoryOverviewResponse = try await networkManager.get(
                    APIService.Endpoint.categoriesOverview,
                    queryItems: queryItems,
                    accessToken: UserDefaults.standard.string(forKey: "bata.authToken")
                )
                overview = response.data
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
