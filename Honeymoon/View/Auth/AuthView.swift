//
//  AuthView.swift
//  Honeymoon
//

import SwiftUI

struct AuthView: View {
    var body: some View {
        NavigationStack {
            LoginView()
        }
        .tint(Color.brand)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
