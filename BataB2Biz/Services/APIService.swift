//
//  APIService.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation

enum APIService {
    static let baseURL = URL(string: "https://bata-dtr-staging.skynetsolutionz.space/api/v1")!

    enum Endpoint {
        static let login = "/auth/login"
        static let register = "/auth/register"
        static let home = "/home"
        static let categoriesOverview = "/catalog/categories-overview"
        static let offers = "/get-offers"
        static let profile = "/profile"
        static let products = "/catalog/products"
        static let cartItems = "/cart/items"
        static let cart = "/cart"
        static let checkout = "/checkout"
        static let checkoutPayLater = "/checkout/pay-later"
        static let orders = "/my-orders"

        static func orderDetail(_ orderID: Int) -> String { "/my-orders/\(orderID)" }
        static func depositSlip(_ orderID: Int) -> String { "/my-orders/\(orderID)/deposit-slip" }
        static let clearCart = "/cart/clear"

        static func cartItem(_ cartItemID: Int) -> String { "/cart/items/\(cartItemID)" }

        static func productDetail(_ productID: Int) -> String {
            "/catalog/products/\(productID)"
        }
    }
}
