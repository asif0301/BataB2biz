import Foundation
import Observation

@Observable
@MainActor
final class OffersViewModel {
    private let networkManager: NetworkManager
    var data: OffersData?
    var isLoading = false
    var errorMessage = ""

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func loadOffers(forceReload: Bool = false) {
        guard !isLoading else { return }
        if forceReload { data = nil }
        isLoading = true
        errorMessage = ""

        Task { [weak self] in
            guard let self else { return }
            do {
                let response: OffersResponse = try await networkManager.get(
                    APIService.Endpoint.offers,
                    accessToken: UserDefaults.standard.string(forKey: "bata.authToken")
                )
                data = response.data
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
