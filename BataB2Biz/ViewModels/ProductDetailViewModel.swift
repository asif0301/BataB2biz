import Foundation
import Observation

@Observable
@MainActor
final class ProductDetailViewModel {
    private let networkManager: NetworkManager
    let productID: Int
    var data: ProductDetailData?
    var isLoading = false
    var errorMessage = ""
    var isAddingToCart = false
    var cartMessage = ""
    var cartErrorMessage = ""

    init(productID: Int, networkManager: NetworkManager = .shared) {
        self.productID = productID
        self.networkManager = networkManager
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = ""
        Task { [weak self] in
            guard let self else { return }
            do {
                let response: ProductDetailResponse = try await networkManager.get(
                    APIService.Endpoint.productDetail(productID),
                    accessToken: UserDefaults.standard.string(forKey: "bata.authToken")
                )
                data = response.data
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    func addToCart(packQuantity: Int) async {
        guard let product = data?.product,
              let packCodeID = product.packCodeID?.trimmingCharacters(in: .whitespacesAndNewlines),
              !packCodeID.isEmpty else {
            cartErrorMessage = "This product is out of stock."
            return
        }

        isAddingToCart = true
        cartMessage = ""
        cartErrorMessage = ""
        do {
            let request = AddCartItemsRequest(items: [
                AddCartItem(productID: product.id, packCodeID: packCodeID, packQuantity: packQuantity)
            ])
            let response: CartResponse = try await networkManager.post(
                request,
                to: APIService.Endpoint.cartItems,
                accessToken: UserDefaults.standard.string(forKey: "bata.authToken")
            )
            if response.success {
                cartMessage = response.message
            } else {
                cartErrorMessage = response.message
            }
        } catch {
            cartErrorMessage = error.localizedDescription
        }
        isAddingToCart = false
    }
}
