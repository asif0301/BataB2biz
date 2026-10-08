import Foundation

struct CartSnapshotResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: CartSnapshot
}

struct CartSnapshot: Decodable {
    let cartID: Int
    var cartItems: [CartItem]
    let deliveryAddress: CartDeliveryAddress?
    let userBalanceInfo: CartBalanceInfo?
    let summary: CartSummary

    enum CodingKeys: String, CodingKey {
        case cartID = "cart_id"
        case cartItems = "cart_items"
        case deliveryAddress = "delivery_address"
        case userBalanceInfo = "user_balance_info"
        case summary
    }
}

struct CartItem: Decodable, Identifiable {
    let productID: Int
    let packCodeID: String?
    let article: String
    let brand: String
    let category: String
    let subCategory: String
    let title: String
    let image: String?
    let packCode: String?
    let packCodeDescription: String?
    let pairsPerPack: Int
    var packQuantity: Int
    let availablePacks: Int?
    let retailTotal: Double
    let totalPairs: Int
    let retailPrice: Double
    let offerPrice: Double
    let unitPrice: Double
    let taxAmount: Double
    let seasonalDiscount: Double
    let discountAmount: Double
    let totalAmount: Double
    let id: Int

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case packCodeID = "pack_code_id"
        case article, brand, category, title, image
        case subCategory = "sub_category"
        case packCode = "pack_code"
        case packCodeDescription = "pack_code_description"
        case pairsPerPack = "pairs_per_pack"
        case packQuantity = "pack_qty"
        case availablePacks = "available_packs"
        case retailTotal = "retail_total"
        case totalPairs = "total_pairs"
        case retailPrice = "retail_price"
        case offerPrice = "offer_price"
        case unitPrice = "unit_price"
        case taxAmount = "tax_amount"
        case seasonalDiscount = "seasonal_discount"
        case discountAmount = "discount_amount"
        case totalAmount = "total_amount"
        case id
    }
}

struct CartDeliveryAddress: Decodable {
    let addressID: String
    let title: String
    let fullAddress: String
    enum CodingKeys: String, CodingKey { case addressID = "address_id"; case title; case fullAddress = "full_address" }
}

struct CartBalanceInfo: Decodable {
    let availableBalance: Double
    let payableBalance: Double
    enum CodingKeys: String, CodingKey { case availableBalance = "available_balance"; case payableBalance = "payable_balance" }
}

struct CartSummary: Decodable {
    let totalProducts: Int
    let totalPacks: Int
    let totalPairs: Int
    let valueHRT: Double
    let discountPercentage: Double
    let discountAmount: Double
    let seasonalDiscount: Double
    let volumeDiscount: Double
    let couponCode: Double
    let grossTotal: Double
    let salesTaxRate: Double
    let salesTaxAmount: Double
    let furtherGSTAmount: Double
    let totalPayable: Double

    enum CodingKeys: String, CodingKey {
        case totalProducts = "total_products"; case totalPacks = "total_packs"; case totalPairs = "total_pairs"
        case valueHRT = "value_hrt"; case discountPercentage = "discount_percentage"; case discountAmount = "discount_amount"
        case seasonalDiscount = "seasonal_discount"; case volumeDiscount = "volume_discount"; case couponCode = "coupon_code"
        case grossTotal = "gross_total"; case salesTaxRate = "sales_tax_rate"; case salesTaxAmount = "sales_tax_amount"
        case furtherGSTAmount = "further_gst_amount"; case totalPayable = "total_payable"
    }
}
