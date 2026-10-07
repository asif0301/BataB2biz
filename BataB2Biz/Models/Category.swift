//
//  Category.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation

struct CategoryOverviewResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: CategoryOverviewData
}

struct CategoryOverviewData: Decodable {
    let parentCategories: [ParentCategory]
    let subCategories: [SubCategory]
    let topBrands: [TopBrand]

    enum CodingKeys: String, CodingKey {
        case parentCategories = "parent_categories"
        case subCategories = "sub_categories"
        case topBrands = "top_brands"
    }
}

struct ParentCategory: Decodable, Identifiable {
    let code: String
    let name: String

    var id: String { code }
}
struct SubCategory: Decodable, Identifiable, Hashable {

    let id: String
    let name: String?
    let subCategoryCode: String
    let categoryCode: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case subCategoryCode = "sub_cat_code"
        case categoryCode = "category_code"
        case imageURL = "image_url"
    }
}

//struct SubCategory: Decodable, Identifiable {
//    let id: String
//    let name: String?
//    let subCategoryCode: String
//    let categoryCode: String
//    let imageURL: String
//
//    enum CodingKeys: String, CodingKey {
//        case id, name
//        case subCategoryCode = "sub_cat_code"
//        case categoryCode = "category_code"
//        case imageURL = "image_url"
//    }
//}

struct TopBrand: Decodable, Identifiable {
    let id: Int
    let name: String
    let code: String
}
