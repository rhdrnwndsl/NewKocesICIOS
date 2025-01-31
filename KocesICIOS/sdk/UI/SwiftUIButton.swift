//
//  SwiftUIButton.swift
//  osxapp
//
//  Created by 신진우 on 2021/04/08.
//

import SwiftUI

struct SwiftUIButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .foregroundColor(Color(UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0)))
            .padding(.horizontal,25)
            .padding(.vertical,10)
//            .padding(.all,20)
//            .frame(width: 120, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color(UIColor(displayP3Red: 0/255, green:113/255, blue: 188/255, alpha: 100.0)),
                                  lineWidth: 3, antialiased: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            )
            

    }
}
