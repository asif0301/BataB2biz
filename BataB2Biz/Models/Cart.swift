import Foundation

struct AddCartItemsRequest: Encodable {
    let items: [AddCartItem]
}

struct AddCartItem: Encodable {
    let productID: Int
    let packCodeID: String
    let packQuantity: Int

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case packCodeID = "pack_code_id"
        case packQuantity = "pack_qty"
    }
}

struct CartResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String

    enum CodingKeys: String, CodingKey {
        case status, success, message
    }
}
