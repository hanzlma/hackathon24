//
//  RoundedPrimaryButton.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


import SwiftUI

struct RoundedButton: View {
    var text: String
    var image: Image? = nil
    var setMaxWidth: Bool? = false
    var background: Color = .primaryColor
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let image = image {
                    image
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.primaryTextColor)
                        .padding(.trailing, 5)
                }
                Text(text)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryTextColor)
            }
            .padding()
            .frame(maxWidth: setMaxWidth ?? false ? .infinity : nil)
            .background(background)
            .cornerRadius(30)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
