//
//  Product.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation

struct HomeResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: HomeData
}

struct HomeData: Decodable {
    let view: String
    let hero: HomeHero
    let summaryCards: [SummaryCard]
    let quickActions: [QuickAction]
    let unreadNotifications: Int

    enum CodingKeys: String, CodingKey {
        case view, hero
        case summaryCards = "summary_cards"
        case quickActions = "quick_actions"
        case unreadNotifications = "unread_notifications"
    }
}

struct HomeHero: Decodable {
    let title: String
    let subtitle: String
    let featuredOffer: FeaturedOffer?
    let featuredProduct: HomeProduct?

    enum CodingKeys: String, CodingKey {
        case title, subtitle
        case featuredOffer = "featured_offer"
        case featuredProduct = "featured_product"
    }
}

struct FeaturedOffer: Decodable {
    let id: String
    let code: String
    let title: String
    let discountType: String
    let discountValue: Double
    let maxDiscountAmount: Double?

    enum CodingKeys: String, CodingKey {
        case id, code, title
        case discountType = "discount_type"
        case discountValue = "discount_value"
        case maxDiscountAmount = "max_discount_amount"
    }
}

struct HomeProduct: Decodable {
    let id: Int
    let title: String
    let article: String?
    let brand: String?
    let pricing: ProductPricing?
    let media: ProductMedia?

    enum CodingKeys: String, CodingKey {
        case id, title, article, brand, pricing, media
    }
}

struct ProductPricing: Decodable {
    let retailPrice: Double?
    let offerPrice: Double?

    enum CodingKeys: String, CodingKey {
        case retailPrice = "retail_price"
        case offerPrice = "offer_price"
    }
}

struct ProductMedia: Decodable {
    let images: [ProductImage]
}

struct ProductImage: Decodable {
    let url: String
    let type: String?
    let altText: String?

    enum CodingKeys: String, CodingKey {
        case url, type
        case altText = "alt_text"
    }
}

struct SummaryCard: Decodable, Identifiable {
    let key: String
    let label: String
    let value: Int

    var id: String { key }
}

struct QuickAction: Decodable, Identifiable {
    let key: String
    let label: String
    let badge: String
    let subtitle: String

    var id: String { key }
}
