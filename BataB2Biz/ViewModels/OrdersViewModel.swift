import Foundation
import Observation

@Observable
@MainActor
final class OrdersViewModel {
    private let networkManager: NetworkManager
    var orders: [OrderSummary] = []
    var counts: OrderCounts?
    var isLoading = false
    var isLoadingMore = false
    var errorMessage = ""
    private var currentPage = 0
    private var lastPage = 1
    private var currentStatus = "all"

    init(networkManager: NetworkManager = .shared) { self.networkManager = networkManager }

    func load(status: String = "all") {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = ""
        currentPage = 0
        lastPage = 1
        currentStatus = status
        orders = []
        fetch(page: 1, append: false)
    }

    func loadMoreIfNeeded(after order: OrderSummary) {
        guard order.id == orders.last?.id,
              !isLoading,
              !isLoadingMore,
              currentPage < lastPage else { return }
        fetch(page: currentPage + 1, append: true)
    }

    private func fetch(page: Int, append: Bool) {
        if append { isLoadingMore = true }
        let authToken = UserDefaults.standard.string(forKey: "bata.authToken")
        Task { [weak self, networkManager, authToken] in
            guard let self else { return }
            do {
                let response: OrdersResponse = try await networkManager.get(
                    APIService.Endpoint.orders,
                    queryItems: [
                        URLQueryItem(name: "status", value: currentStatus),
                        URLQueryItem(name: "page", value: String(page))
                    ],
                    accessToken: authToken
                )
                if append {
                    orders.append(contentsOf: response.data.items)
                } else {
                    orders = response.data.items
                }
                counts = response.data.counts
                currentPage = response.data.meta.currentPage
                lastPage = response.data.meta.lastPage
            } catch {
                errorMessage = error.localizedDescription
            }
            if append {
                isLoadingMore = false
            } else {
                isLoading = false
            }
        }
    }
}
