//
//  RoundedPrimaryButton.swift
//  atthack24
//
//  Created by Tom on 28.11.2024.
//


import SwiftUI

struct RoundedButton: View {
    var text: String
    var image: Image? = nil // Optional image
    var setMaxWidth: Bool? = false // Optional image
    var background: Color = .primaryColor
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let image = image {
                    image
                        .resizable()
                        .frame(width: 20, height: 20) // Adjust size as needed
                        .foregroundColor(.primaryTextColor) // Ensure the icon color is white
                        .padding(.trailing, 5)
                }
                Text(text)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryTextColor)
            }
            .padding()
            .frame(maxWidth: setMaxWidth ?? false ? .infinity : nil) // Makes the button stretch horizontally
            .background(background)
            .cornerRadius(30) // Rounded corners
            //.shadow(radius: 5) // Optional shadow for a better look
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button style
    }
}



/*
 //EXAMPLE OF USAGE:
 
 RoundedButton(
     text: "Click Me",
     image: Image(systemName: "bus.fill")
 ) {
     print("Button clicked!")
 }
 .padding()
 
 RoundedButton(
     text: "No Image Button"
 ) {
     print("Another button clicked!")
 }
 .padding()
 
 
 
 
 */
