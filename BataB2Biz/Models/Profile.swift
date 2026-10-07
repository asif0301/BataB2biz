import Foundation

struct ProfileResponse: Decodable {
    let status: Int
    let success: Bool
    let message: String
    let data: ProfileData
}

struct ProfileData: Decodable {
    let user: ProfileUser
    let addresses: [ProfileAddress]
}

struct ProfileUser: Decodable {
    let name: String
    let email: String
    let phone: String
    let profileImage: String?
    let businessName: String?
    let businessType: String?
    let city: String?
    let contactPersonName: String?

    enum CodingKeys: String, CodingKey {
        case name, email, phone, city
        case profileImage = "profile_image"
        case businessName = "business_name"
        case businessType = "business_type"
        case contactPersonName = "contact_person_name"
    }
}

struct ProfileAddress: Decodable, Identifiable {
    let id: String
    let label: String?
    let contactPerson: String?
    let phoneNumber: String?
    let street: String?
    let city: String?
    let postalCode: String?
    let province: String?
    let isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id, label, city, street, province
        case contactPerson = "contact_person"
        case phoneNumber = "phone_number"
        case postalCode = "postal_code"
        case isDefault = "is_default"
    }
}
