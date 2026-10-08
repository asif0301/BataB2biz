import Foundation

struct ProductDetailResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: ProductDetailData
}

struct ProductDetailData: Decodable {
    let product: OfferProduct
    let similar: [OfferProduct]
    let detectedType: String?
    let packCodes: [PackCode]

    enum CodingKeys: String, CodingKey {
        case product, similar
        case detectedType = "detected_type"
        case packCodes = "pack_codes"
    }
}

struct PackCode: Decodable, Identifiable {
    let id: String
    let packCodeID: String?
    let code: String?
    let description: String?
    let pairsPerPack: Int
    let availablePacks: Int?
    let inStock: Bool?
    let types: [PackType]

    enum CodingKeys: String, CodingKey {
        case id, code, description, types
        case packCodeID = "pack_code_id"
        case pairsPerPack = "pairs_per_pack"
        case availablePacks = "available_packs"
        case inStock = "in_stock"
    }
}

struct PackType: Decodable {
    let type: String
    let available: Int?
    let totalPairs: Int
    let sizes: [PackSize]

    enum CodingKeys: String, CodingKey {
        case type, available, sizes
        case totalPairs = "total_pairs"
    }
}

struct PackSize: Decodable, Identifiable {
    let sizeID: String
    let size: String
    let quantity: Int
    let available: Int?

    var id: String { sizeID }

    enum CodingKeys: String, CodingKey {
        case size
        case sizeID = "size_id"
        case quantity = "qty"
        case available
    }
}
