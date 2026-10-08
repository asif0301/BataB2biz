import Foundation
import Observation

@Observable
@MainActor
final class CheckoutViewModel {
    private let networkManager: NetworkManager
    var snapshot: CartSnapshot?
    var isLoading = false
    var isPlacingOrder = false
    var errorMessage = ""
    var placeOrderError = ""
    var confirmation: OrderConfirmation?

    init(networkManager: NetworkManager = .shared) {
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
                let response: CartSnapshotResponse = try await networkManager.get(
                    APIService.Endpoint.checkout,
                    accessToken: authToken
                )
                snapshot = response.data
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func placeOrder(notes: String) {
        guard let snapshot, let addressID = snapshot.deliveryAddress?.addressID else {
            placeOrderError = "Please select a delivery address."
            return
        }
        guard !isPlacingOrder else { return }
        isPlacingOrder = true
        placeOrderError = ""
        let request = PayLaterCheckoutRequest(cartID: snapshot.cartID, addressID: addressID, notes: notes)
        let authToken = UserDefaults.standard.string(forKey: "bata.authToken")
        Task { [weak self, networkManager, authToken] in
            guard let self else { return }
            do {
                let response: PayLaterCheckoutResponse = try await networkManager.post(request, to: APIService.Endpoint.checkoutPayLater, accessToken: authToken)
                confirmation = response.data.confirmation
            } catch {
                placeOrderError = error.localizedDescription
            }
            isPlacingOrder = false
        }
    }
}
