import Foundation
import Observation

@Observable
@MainActor
final class CartViewModel {
    private let networkManager: NetworkManager
    var snapshot: CartSnapshot?
    var isLoading = false
    var isMutating = false
    var errorMessage = ""
    var actionMessage = ""

    init(networkManager: NetworkManager = .shared) { self.networkManager = networkManager }

    func load() {
        guard !isLoading else { return }
        isLoading = true; errorMessage = ""
        Task { [weak self] in
            guard let self else { return }
            do {
                let response: CartSnapshotResponse = try await networkManager.get(APIService.Endpoint.cart, accessToken: token)
                snapshot = response.data
            } catch { errorMessage = error.localizedDescription }
            isLoading = false
        }
    }

    func remove(itemID: Int) {
        let authToken = token
        mutate { [networkManager, authToken] in
            let response: CartSnapshotResponse = try await networkManager.delete(APIService.Endpoint.cartItem(itemID), accessToken: authToken)
            return response
        }
    }

    func clear() {
        let authToken = token
        mutate { [networkManager, authToken] in
            let response: CartSnapshotResponse = try await networkManager.delete(APIService.Endpoint.clearCart, accessToken: authToken)
            return response
        }
    }

    private func mutate(_ request: @escaping () async throws -> CartSnapshotResponse) {
        guard !isMutating else { return }
        isMutating = true; actionMessage = ""
        Task { [weak self] in
            guard let self else { return }
            do { let response = try await request(); snapshot = response.data; actionMessage = response.message }
            catch { actionMessage = error.localizedDescription }
            isMutating = false
        }
    }

    private var token: String? { UserDefaults.standard.string(forKey: "bata.authToken") }
}
