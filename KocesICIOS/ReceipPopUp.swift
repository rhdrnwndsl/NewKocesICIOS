//
//  PopUp.swift
//  osxapp
//
//  Created by 金載龍 on 2021/02/17.
//

import SwiftUI

struct ReceipPopUp: View {
    @Binding var show: Bool
    @State var str:String = ""
    var body: some View {
        ZStack{
            VStack{
            Text("번호를 입력해 주세요")
                Text("Placeholder")
                TextField(/*@START_MENU_TOKEN@*/"Placeholder"/*@END_MENU_TOKEN@*/, text: $str)
            }
        }
    }
}

