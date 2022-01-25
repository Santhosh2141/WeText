//
//  SearchBar.swift
//  WeText
//
//  Created by Santhosh Srinivas on 17/12/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchBarInChat: View {
    
    @ObservedObject var vm: ChatLogViewModel
    @Binding var text: String
    @State var isEditing = false
    @State var show = false
    
    var body: some View {
        HStack{
            if !self.show{
                HStack{
                    WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                        .resizable()
                        .scaledToFill().frame(width: 30, height: 30)
                        .clipped()
                        .cornerRadius(30)
                        .overlay(RoundedRectangle(cornerRadius: 30) .stroke(.black, lineWidth: 2))
//                        .shadow(color: .black, radius: 2.5)
                        .offset(x: -50)
//                        .shadow(color: .black, radius: 2.5)
                    Text("\(vm.chatUser?.uName ?? "")")
//                        .fontWeight(.bold)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .offset(x: -50)

                        .padding(.leading)
                }
//                .padding(.vertical)
            }
            
            Spacer(minLength: 0)
            if self.show {
                TextField("Search...", text: $text)
                    .padding(5)
                    .padding(.horizontal,40)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                    .offset(x: -50)
                    .overlay(
                        HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .offset(x: -50)
                            
                        }
                    ).onTapGesture {
                        self.isEditing = true
                    }
                if isEditing{
                    Button{
                        self.text = ""
                        self.isEditing = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        withAnimation {
                            
                            self.show.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
//                            .frame(width: 20, height: 20, alignment: .trailing)
//                            .offset(x: -50)
                    }
                }
            } else {
                    Button{
                        
                        withAnimation {
                            
                            self.show.toggle()
                        }
                        
                    } label: {
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .padding(10)
                            .offset(x: 20)
                    }
//                    .foregroundColor(.blue)
                    .padding(!self.show ? 10 : 0)
//                    .background(Color.white)
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal,10)
    }
}


