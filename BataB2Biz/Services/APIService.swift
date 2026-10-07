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
    }
}
