//
//  ContentView.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("bata.authToken") private var authToken = ""
    @AppStorage("bata.rememberMe") private var rememberMe = false

    var body: some View {
        if rememberMe && !authToken.isEmpty {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
