//
//  SettingView.swift
//  MSG
//
//  Created by zooey on 2023/01/18.
//
import SwiftUI

struct SettingView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var fireStoreViewModel: FireStoreViewModel
    @State var userProfile: Msg?
    @Binding var darkModeEnabled: Bool
    
    var frameWidth = UIScreen.main.bounds.width
    var frameHeight = UIScreen.main.bounds.height
    
    var body: some View {
        
        GeometryReader { g in
            ZStack {
                Color("Color1").ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color("Color1"),
                                    lineWidth: 4)
                            .shadow(color: Color("Shadow"),
                                    radius: 3, x: 5, y: 5)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15))
                            .shadow(color: Color("Shadow3"), radius: 2, x: -2, y: -2)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15))
                            .background(Color("Color1"))
                            .cornerRadius(20)
                            .frame(width: g.size.width / 1.1, height: g.size.height / 4)
                        
                        VStack {
                            VStack {
                                // 조건 써주기
                                if userProfile == nil || userProfile!.profileImage.isEmpty{
                                    Image(systemName: "person.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: g.size.width / 3, height: g.size.height / 7)
                                } else {
                                    // 사진 불러오기
                                    AsyncImage(url: URL(string: userProfile!.profileImage)) { Image in
                                        Image
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: g.size.width / 3, height: g.size.height / 7)
                                    } placeholder: { }
                                }
                            }
                            .frame(height: g.size.height / 7)
                            
                            HStack {
                                Text( userProfile != nil ? userProfile!.nickName : "닉네임")
                                    .modifier(TextViewModifier(color: "Color2"))
                                    .padding(.top)
                                    .padding(.leading)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 18) {
                        Toggle("다크모드 활성화", isOn: $darkModeEnabled)
                            .onChange(of: darkModeEnabled) { _ in
                                SystemThemeManager
                                    .shared
                                    .handleTheme(darkMode: darkModeEnabled)
                            }
                        
                        Button {
                            
                        } label: {
                            Text("프로필 편집")
                        }
                        
                        Text("알림 설정")
                        
                        // 이메일, sms, 공유하기, 시트뷰로 보여주기
                        Text("친구 초대")
                        
                        Button {
                            loginViewModel.signout()
                        } label: {
                            Text("로그아웃")
                        }
                        Spacer()
                        Button {
                            Task {
                                await fireStoreViewModel.deleteUser()
                                loginViewModel.deleteUser()
                            }
                
                            
                        } label: {
                            Text("회원탈퇴//누르면 얼럿안뜨고 삭제됨 조심")
                        }
                    }
                    .modifier(TextViewModifier(color: "Color2"))
                    
                    VStack {
                        // 프레임 맞추려고 있는 VStack
                    }
                    .frame(height: g.size.height / 4)
                }
                .padding()
            }
            .foregroundColor(Color("Color2"))
            .onAppear{
                if loginViewModel.currentUserProfile != nil{
                    self.userProfile = loginViewModel.currentUserProfile
                }
                
            }
            .foregroundColor(Color("Color2"))
        }
    }
}

struct SettignView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(darkModeEnabled: .constant(false))
    }
}
