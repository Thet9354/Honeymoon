//
//  FooterView.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 31/10/23.
//

import SwiftUI

struct FooterView: View {
    
    // MARK: - PROPERTIES
    @Binding var showBookingAlert: Bool
    var onBook: () -> Void = {}


    var body: some View {
        HStack {
            Image(systemName: "xmark.circle")
                .font(.system(size: 42, weight: .light))
                .accessibilityHidden(true)

            Spacer()

            Button(action: {
                SoundPlayer.shared.play(.booking)
                self.onBook()
                self.showBookingAlert.toggle()
            }) {
                Text("Book Destination".uppercased())
                    .font(.system(.subheadline, design: .rounded))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .accentColor(Color.brand)
                    .background(
                        Capsule()
                            .stroke(Color.brand, lineWidth: 2)
                    )
            }
            .accessibilityLabel("Book destination")
            .accessibilityHint("Confirms a booking for the current destination")

            Spacer()

            Image(systemName: "heart.circle")
                .font(.system(size: 42, weight: .light))
                .accessibilityHidden(true)
        }
        .padding()
    }
}

struct FooterView_Previews: PreviewProvider {
    
    @State static var showAlert: Bool = false
    
    static var previews: some View {
        FooterView(showBookingAlert: $showAlert)
            .previewLayout(.fixed(width: 375, height: 80))
    }
}
