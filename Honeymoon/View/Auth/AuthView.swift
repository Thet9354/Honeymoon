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
        .tint(Color.pink)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
