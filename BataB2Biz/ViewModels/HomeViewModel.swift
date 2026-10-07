//
//  HomeViewModel.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    private let networkManager: NetworkManager
    var home: HomeData?
    var isLoading = false
    var errorMessage = ""

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func loadHome(forceReload: Bool = false) {
        guard !isLoading else { return }
        if forceReload {
            home = nil
        }
        isLoading = true
        errorMessage = ""

        Task { [weak self] in
            guard let self else { return }
            if forceReload {
                try? await Task.sleep(for: .milliseconds(450))
            }
            do {
                let response: HomeResponse = try await networkManager.get(
                    APIService.Endpoint.home,
                    queryItems: [URLQueryItem(name: "view", value: "mobile")],
                    accessToken: UserDefaults.standard.string(forKey: "bata.authToken")
                )
                home = response.data
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
