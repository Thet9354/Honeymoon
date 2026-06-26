//
//  AcknowledgementsView.swift
//  Honeymoon
//

import SwiftUI

struct AcknowledgementsView: View {

    private let photographers: String = """
    Shifaaz Shamoon (Maldives), Grillot Edouard (France), Evan Wise (Greece), \
    Christoph Schulz (United Arab Emirates), Andrew Coelho (USA), Damiano \
    Baschiera (Italy), Daniel Olah (Hungary), Andrzej Rusinowski (Poland), \
    Lucas Miguel (Slovenia), Florencia Potter (Spain), Ian Simmonds (USA), \
    Ian Keefe (Canada), Denys Nevozhai (Thailand), David Köhler (Italy), \
    Andre Benz (USA), Alexandre Chambon (South Korea), Roberto Nickson \
    (Mexico), Ajit Paul Abraham (UK), Jeremy Bishop (USA), Davi Costa \
    (Brazil), Liam Pozz (Australia).
    """

    var body: some View {
        List {
            Section("Photos") {
                LabeledContent("Source", value: "Unsplash")
            }

            Section("Photographers") {
                Text(photographers)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Acknowledgements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsView()
    }
}
