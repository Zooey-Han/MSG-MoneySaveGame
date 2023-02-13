//
//  FriendView.swift
//  MSG
//
//  Created by kimminho on 2023/01/17.
//

import SwiftUI

struct ChallengeFriendSheetView: View {
    @StateObject var challengeFriendViewModel = ChallengeFriendViewModel()
    @State var checked = false
    
}

extension ChallengeFriendSheetView {
    
    var body: some View {
        
        GeometryReader { g in
            ZStack {
                Color("Color1")
                    .ignoresSafeArea()
                
                VStack {
                    ScrollView {
                        
                        if challengeFriendViewModel.myFrinedArray.isEmpty {
                            VStack{
                                Text("현재 추가되어있는 친구가 없습니다.")
                                    .modifier(TextModifier(fontWeight: FontCustomWeight.bold, fontType: FontCustomType.title2, color: FontCustomColor.color2))
                                    .padding(.bottom, 1)
                                
                                Text("친구목록에서 친구를 추가해주세요!")
                                    .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.body, color: FontCustomColor.color2))
                                
                            } .frame(width: g.size.width / 1.04, height: g.size.height / 1)
                        } else if challengeFriendViewModel.notGamePlayFriend.isEmpty {
                            VStack{
                                
                                Text("현재 모든 친구가 도전중입니다.")
                                    .modifier(TextModifier(fontWeight: FontCustomWeight.bold, fontType: FontCustomType.title2, color: FontCustomColor.color2))
                                    .frame(width: g.size.width / 1.04, height: g.size.height / 1)
                            }
                        } else {
                            
                            ForEach(challengeFriendViewModel.notGamePlayFriend) { user in
                                ChallengeFriendViewCell(user: user, challengeFriendViewModel: challengeFriendViewModel,checked: $checked)
                                    .frame(height: 60)
                                    .listRowBackground(Color("Color1"))
                                    .listRowSeparator(.hidden)
                            }
                        }
                        
                    }
                }
            }
            .onAppear {
                Task {
                    await challengeFriendViewModel.getMyFriendArray()
                    try await challengeFriendViewModel.getMyFriendForNotGame()
                }
                print("== FriendVeiw onAppear ==")
                
            }
            .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.body, color: FontCustomColor.color2))
        }
    }
}

struct FriendView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeFriendSheetView()
    }
}
