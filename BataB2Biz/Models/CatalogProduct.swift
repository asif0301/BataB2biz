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

    enum CodingKeys: String, CodingKey {
        case quickPills = "quick_pills"
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
