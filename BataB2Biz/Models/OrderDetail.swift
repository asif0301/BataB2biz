import Foundation

struct OrderDetailResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: OrderDetailData
}

struct OrderDetailData: Decodable {
    let order: OrderDetail
}

struct OrderDetail: Decodable {
    let orderID: Int
    let orderNumber: String
    let orderStatus: String
    let statusLabel: String
    let totalProducts: Int
    let totalPacks: Int
    let totalPairs: Int
    let totalPayable: Double
    let paymentStatusLabel: String
    let trackingNumber: String?
    let deliveryStatusLabel: String
    let items: [OrderDetailItem]
    let timeline: OrderTimeline
    let depositSlip: DepositSlip

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderNumber = "order_number"
        case orderStatus = "order_status"
        case statusLabel = "status_label"
        case totalProducts = "total_products"
        case totalPacks = "total_packs"
        case totalPairs = "total_pairs"
        case totalPayable = "total_payable"
        case paymentStatusLabel = "payment_status_label"
        case trackingNumber = "tracking_number"
        case deliveryStatusLabel = "delivery_status_label"
        case items, timeline
        case depositSlip = "deposit_slip"
    }
}

struct OrderDetailItem: Decodable, Identifiable {
    let id: Int
    let article: String
    let title: String
    let image: String?
    let packCode: String?
    let packQuantity: Int
    let totalPairs: Int

    enum CodingKeys: String, CodingKey {
        case id, article, title, image
        case packCode = "pack_code"
        case packQuantity = "pack_qty"
        case totalPairs = "total_pairs"
    }
}

struct OrderTimeline: Decodable {
    let steps: [OrderTimelineStep]
}

struct OrderTimelineStep: Decodable, Identifiable {
    let key: String
    let label: String
    let completed: Bool
    let active: Bool
    let occurredAt: String?

    var id: String { key }

    enum CodingKeys: String, CodingKey {
        case key, label, completed, active
        case occurredAt = "occurred_at"
    }
}

struct DepositSlip: Decodable {
    let canUpload: Bool
    let remainingSubmittableAmount: Double

    enum CodingKeys: String, CodingKey {
        case canUpload = "can_upload"
        case remainingSubmittableAmount = "remaining_submittable_amount"
    }
}
