import Foundation

struct CatalogProductsResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: CatalogProductsData
}

struct CatalogProductsData: Decodable {
    let filtersData: CatalogFiltersData?
    let products: CatalogProductPage

    enum CodingKeys: String, CodingKey {
        case filtersData = "filters_data"
        case products
    }
}

struct CatalogFiltersData: Decodable {
    let quickPills: [CatalogQuickPill]
    let categories: [CatalogFilterOption]
    let subCategories: [CatalogFilterOption]
    let brands: [CatalogFilterOption]
    let priceRangeBounds: CatalogPriceRangeBounds

    enum CodingKeys: String, CodingKey {
        case quickPills = "quick_pills"
        case categories
        case subCategories = "sub_categories"
        case brands
        case priceRangeBounds = "price_range_bounds"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quickPills = try container.decodeIfPresent([CatalogQuickPill].self, forKey: .quickPills) ?? []
        categories = try container.decodeIfPresent([CatalogFilterOption].self, forKey: .categories) ?? []
        subCategories = try container.decodeIfPresent([CatalogFilterOption].self, forKey: .subCategories) ?? []
        brands = try container.decodeIfPresent([CatalogFilterOption].self, forKey: .brands) ?? []
        priceRangeBounds = try container.decodeIfPresent(CatalogPriceRangeBounds.self, forKey: .priceRangeBounds) ?? CatalogPriceRangeBounds(minPrice: 0, maxPrice: 0)
    }
}

struct CatalogPriceRangeBounds: Decodable {
    let minPrice: Double
    let maxPrice: Double

    enum CodingKeys: String, CodingKey {
        case minPrice = "min_price"
        case maxPrice = "max_price"
    }
}

struct CatalogFilterOption: Decodable, Identifiable {
    let code: String
    let name: String?
    let categoryCode: String?
    var id: String { code }

    enum CodingKeys: String, CodingKey {
        case code, name
        case categoryCode = "category_code"
    }
}

struct CatalogQuickPill: Decodable, Identifiable {
    let label: String
    let value: String
    var id: String { value }
}

struct CatalogProductPage: Decodable {
    let items: [OfferProduct]
    let meta: CatalogPagination
}

struct CatalogPagination: Decodable {
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
