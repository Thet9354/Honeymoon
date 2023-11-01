//
//  TitleModifier.swift
//  Honeymoon
//
//  Created by Phoon Thet Pine on 1/11/23.
//

import SwiftUI

struct TitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(Color.pink)
    }
}
