import Foundation

struct PayLaterCheckoutRequest: Encodable {
    let cartID: Int
    let addressID: String
    let notes: String
    enum CodingKeys: String, CodingKey { case cartID = "cart_id"; case addressID = "address_id"; case notes }
}

struct PayLaterCheckoutResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: PayLaterCheckoutData
}

struct PayLaterCheckoutData: Decodable {
    let orderID: Int
    let cartID: Int
    let orderStatus: String
    let paymentStatus: String
    let confirmation: OrderConfirmation
    enum CodingKeys: String, CodingKey { case orderID = "order_id"; case cartID = "cart_id"; case orderStatus = "order_status"; case paymentStatus = "payment_status"; case confirmation }
}

struct OrderConfirmation: Decodable {
    let title: String
    let orderNumber: String
    let statusLabel: String
    let totalProducts: Int
    let totalPacks: Int
    let totalPairs: Int
    let totalPayable: Double
    let expectedDeliveryDate: String?
    enum CodingKeys: String, CodingKey {
        case title
        case orderNumber = "order_number"
        case statusLabel = "status_label"
        case totalProducts = "total_products"
        case totalPacks = "total_packs"
        case totalPairs = "total_pairs"
        case totalPayable = "total_payable"
        case expectedDeliveryDate = "expected_delivery_date"
    }
}
