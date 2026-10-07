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
    let subCategories: [CatalogFilterOption]
    let brands: [CatalogFilterOption]

    enum CodingKeys: String, CodingKey {
        case quickPills = "quick_pills"
        case subCategories = "sub_categories"
        case brands
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        quickPills = try container.decodeIfPresent([CatalogQuickPill].self, forKey: .quickPills) ?? []
        subCategories = try container.decodeIfPresent([CatalogFilterOption].self, forKey: .subCategories) ?? []
        brands = try container.decodeIfPresent([CatalogFilterOption].self, forKey: .brands) ?? []
    }
}

struct CatalogFilterOption: Decodable, Identifiable {
    let code: String
    let name: String?
    var id: String { code }

    enum CodingKeys: String, CodingKey {
        case code, name
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
