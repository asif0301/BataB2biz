import Foundation

struct OrdersResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: OrdersData
}

struct OrdersData: Decodable {
    let items: [OrderSummary]
    let counts: OrderCounts?
    let meta: OrdersPagination
}

struct OrdersPagination: Decodable {
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}

struct OrderSummary: Decodable, Identifiable {
    let orderID: Int
    let orderNumber: String
    let orderStatus: String
    let status: String
    let statusLabel: String
    let totalProducts: Int
    let totalPacks: Int
    let totalPairs: Int
    let totalPayable: Double
    let createdAt: String

    var id: Int { orderID }

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderNumber = "order_number"
        case orderStatus = "order_status"
        case status
        case statusLabel = "status_label"
        case totalProducts = "total_products"
        case totalPacks = "total_packs"
        case totalPairs = "total_pairs"
        case totalPayable = "total_payable"
        case createdAt = "created_at"
    }
}

struct OrderCounts: Decodable {
    let all: Int
    let reserved: Int
    let paymentReceived: Int
    let inProcess: Int
    let onHold: Int
    let readyForDispatch: Int
    let shipped: Int
    let delivered: Int
    let completed: Int
    let cancelled: Int

    enum CodingKeys: String, CodingKey {
        case all, reserved
        case paymentReceived = "payment_received"
        case inProcess = "in_process"
        case onHold = "on_hold"
        case readyForDispatch = "ready_for_dispatch"
        case shipped, delivered, completed, cancelled
    }
}
