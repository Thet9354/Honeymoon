//
//  HeaderView.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//

import SwiftUI

struct HeaderView: View {

    // MARK: - PROPERTIES
    @Binding var showGuideView: Bool
    @Binding var showSettingsView: Bool
    @Binding var showSavedView: Bool

    var body: some View {
        HStack {
            Button(action: {
                self.showSettingsView.toggle()
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 24, weight: .regular))
            }
            .accentColor(Color.primary)
            .accessibilityLabel("Settings")
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
            }

            Spacer()

            Image("logo-honeymoon-pink")
                .resizable()
                .scaledToFit()
                .frame(height: 28)

            Spacer()

            HStack(spacing: 18) {
                Button(action: {
                    self.showSavedView.toggle()
                }) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 24, weight: .regular))
                }
                .accentColor(Color.primary)
                .accessibilityLabel("Saved")
                .sheet(isPresented: $showSavedView) {
                    SavedView()
                }

                Button(action: {
                    self.showGuideView.toggle()
                }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 24, weight: .regular))
                }
                .accentColor(Color.primary)
                .accessibilityLabel("How it works")
                .sheet(isPresented: $showGuideView) {
                    GuideView()
                }
            }
        }
        .padding()
    }
}

struct HeaderView_Previews: PreviewProvider {

    @State static var showGuide: Bool = false
    @State static var showSettings: Bool = false
    @State static var showSaved: Bool = false

    static var previews: some View {
        HeaderView(showGuideView: $showGuide, showSettingsView: $showSettings, showSavedView: $showSaved)
            .environmentObject(UserDataStore())
            .previewLayout(.fixed(width: 375, height: 80))
    }
}
