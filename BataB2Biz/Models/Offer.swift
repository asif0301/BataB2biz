import Foundation

struct OffersResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: OffersData
}

struct OffersData: Decodable {
    let offers: [OfferSummary]
    let products: [OfferProduct]
}

struct OfferSummary: Decodable, Identifiable {
    let id: String
    let type: String
    let name: String
    let discountType: String
    let discountValue: Double
    let startDate: String
    let endDate: String

    enum CodingKeys: String, CodingKey {
        case id, type, name
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case startDate = "start_date"
        case endDate = "end_date"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else {
            id = String(try container.decode(Int.self, forKey: .id))
        }
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? "offer"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Offer"
        discountType = try container.decodeIfPresent(String.self, forKey: .discountType) ?? "percentage"
        discountValue = try container.decodeIfPresent(Double.self, forKey: .discountValue) ?? 0
        startDate = try container.decodeIfPresent(String.self, forKey: .startDate) ?? ""
        endDate = try container.decodeIfPresent(String.self, forKey: .endDate) ?? ""
    }
}

struct OfferProduct: Decodable, Identifiable {
    let id: Int
    let title: String
    let article: String?
    let brand: String?
    let isFavourite: Bool?
    let discount: OfferDiscount?
    let badges: OfferBadges?
    let pricing: OfferProductPricing
    let media: ProductMedia?
    let categories: ProductCategories?

    enum CodingKeys: String, CodingKey {
        case id, title, article, brand, discount, badges, pricing, media, categories
        case isFavourite = "is_favourite"
    }
}

struct OfferDiscount: Decodable {
    let discountType: String?
    let discountValue: Double?
    let discountedPrice: Double?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case discountedPrice = "discounted_price"
        case isActive = "is_active"
    }
}

struct OfferBadges: Decodable {
    let discountTag: String?
    let statusBadge: String?

    enum CodingKeys: String, CodingKey {
        case discountTag = "discount_tag"
        case statusBadge = "status_badge"
    }
}

struct OfferProductPricing: Decodable {
    let retailPrice: Double?
    let offerPrice: Double?
    let channelDiscountedPrice: Double?

    enum CodingKeys: String, CodingKey {
        case retailPrice = "retail_price"
        case offerPrice = "offer_price"
        case channelDiscountedPrice = "channel_discounted_price"
    }
}

struct ProductCategories: Decodable {
    let category: ProductCategory?
    let subCategory: ProductCategory?

    enum CodingKeys: String, CodingKey {
        case category
        case subCategory = "sub_category"
    }
}

struct ProductCategory: Decodable {
    let name: String
}
