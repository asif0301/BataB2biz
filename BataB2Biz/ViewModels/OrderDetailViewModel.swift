import Foundation
import Observation

@Observable
@MainActor
final class OrderDetailViewModel {
    private let networkManager: NetworkManager
    let orderID: Int
    var order: OrderDetail?
    var isLoading = false
    var errorMessage = ""

    init(orderID: Int, networkManager: NetworkManager = .shared) {
        self.orderID = orderID
        self.networkManager = networkManager
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = ""
        let authToken = UserDefaults.standard.string(forKey: "bata.authToken")
        Task { [weak self, networkManager, authToken] in
            guard let self else { return }
            do {
                let response: OrderDetailResponse = try await networkManager.get(
                    APIService.Endpoint.orderDetail(orderID),
                    accessToken: authToken
                )
                order = response.data.order
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
