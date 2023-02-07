//
//  SettingView.swift
//  MSG
//
//  Created by zooey on 2023/01/18.
//
import SwiftUI
import PhotosUI

struct SettingView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @EnvironmentObject var fireStoreViewModel: FireStoreViewModel
    @State var userProfile: Msg?
    @Binding var darkModeEnabled: Bool
    @State private var logoutToggle: Bool = false
    @State private var deleteToggle: Bool = false
    @Binding var notificationEnabled: Bool
    @State private var text: String = ""
    @State private var profileEditing: Bool = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        
        GeometryReader { g in
            ZStack {
                Color("Color1").ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 30) {
                    
                    VStack(alignment: .leading) {
                        Text("설정")
                            .modifier(TextModifier(fontWeight: FontCustomWeight.bold, fontType: FontCustomType.largeTitle, color: FontCustomColor.color2))
                        Text("Money Save Game")
                            .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.caption, color: FontCustomColor.color2))
                    }
                    .frame(width: g.size.width / 1.1, height: g.size.height / 8, alignment: .leading)
                    
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
                            if profileEditing == true {
                                VStack {
                                    ZStack {
                                        HStack{
                                            PhotosPicker(
                                                selection: $selectedItem,
                                                matching: .images,
                                                photoLibrary: .shared()) {
                                                    Spacer()
                                                    Text("사진선택   |")
                                                        .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.caption, color: FontCustomColor.color2))
                                                }
                                            Button(action: {
                                                profileEditing = false
                                                if let selectedImageData,
                                                   let uiImage = UIImage(data: selectedImageData) {
                                                    let userProfile = Msg(id: fireStoreViewModel.myInfo?.id ?? "", nickName: userProfile!.nickName, profileImage: fireStoreViewModel.myInfo?.profileImage ?? "", game: fireStoreViewModel.myInfo?.game ?? "")
                                                    Task{
                                                        await fireStoreViewModel.uploadImageToStorage(userImage: uiImage, user: userProfile)
                                                        fireStoreViewModel.myInfo = try await fireStoreViewModel.fetchUserInfo(self.userProfile?.id ?? "")
                                                    }
                                                    
                                                }
                                            }) {
                                                Text("   선택완료    |")
                                                    .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.caption, color: FontCustomColor.color2))
                                            }
                                            
                                            
                                            Button(action: {
                                                selectedImageData = nil
                                                profileEditing = false
                                            }) {
                                                Text("  취소  ")
                                                .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.caption, color: FontCustomColor.color2))
                                            }
                                        }
                                    }
                                    .padding(.trailing)
                                    .padding(.top, -g.size.height / 20.5)
                                    .onChange(of: selectedItem) { newItem in
                                        Task {
                                            // Retrive selected asset in the form of Data
                                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                                selectedImageData = data
                                            }
                                        }
                                    }
                                    
                                    if selectedImageData == nil {
                                        if userProfile == nil || userProfile!.profileImage.isEmpty{
                                            Image(systemName: "person.circle")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: g.size.width / 3, height: g.size.height / 7)
                                        }
                                        else {
                                            // 사진 불러오기
                                            AsyncImage(url: URL(string: userProfile!.profileImage)) { Image in
                                                Image
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: g.size.width / 3, height: g.size.height / 7)
                                            } placeholder: {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width / 3, height: g.size.height / 7)
                                                    .aspectRatio(contentMode: .fill)
                                            }
                                        }
                                        
                                    }
                                    else if profileImage != nil {
                                        
                                        Image(uiImage: profileImage!)
                                            .resizable()
                                            .clipShape(Circle())
                                            .frame(width: g.size.width / 3, height: g.size.height / 7)
                                            .aspectRatio(contentMode: .fill)

                                    } else {
                                        
                                        if let selectedImageData,
                                           let uiImage = UIImage(data: selectedImageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .clipShape(Circle())
                                                .frame(width: g.size.width / 3, height: g.size.height / 7)
                                                .aspectRatio(contentMode: .fill)
                                        }
                                        
                                    }
                                }
                                .frame(height: g.size.height / 6)
                            } else {
                                VStack{
                                    ZStack {
                                        HStack{ Spacer()
                                        }
                                    }
                                    .padding(.trailing)
                                    .padding(.top, -g.size.height / 20)
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
                                                    .aspectRatio(contentMode: .fill)
                                            } placeholder: {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width / 3, height: g.size.height / 7)
                                            }
                                        }
                                    }
                                }
                                .frame(height: g.size.height / 6)
                            }
                            
                            HStack {
                                Text( userProfile != nil ? userProfile!.nickName : "닉네임")
                                    .modifier(TextModifier(fontWeight: FontCustomWeight.bold, fontType: FontCustomType.title3, color: FontCustomColor.color2))
                                    .padding(.top, 5)
                            }
                        }
                    }
                    .frame(width: g.size.width / 1.1, height: g.size.height / 4)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("다크모드")
                            Spacer()
                            DarkModeToggle(width: g.size.width / 4.7, height: g.size.height / 22, toggleWidthOffset: 12, cornerRadius: 15, padding: 4, darkModeEnabled: $darkModeEnabled)
                        }
                        
                        HStack {
                            Text("알림설정")
                            Spacer()
                            NotificationToggle(width: g.size.width / 4.7, height: g.size.height / 22, toggleWidthOffset: 12, cornerRadius: 15, padding: 4, notificationEnabled: $notificationEnabled)
                        }
                        
                        Button {
                            profileEditing.toggle()
                        } label: {
                            Text("프로필 편집")
                        }
                        
                        // 이메일, sms, 공유하기, 시트뷰로 보여주기
                        Button {
                            buttonAction("https://itunes.apple.com/app/", .share)
                        } label: {
                            Text("친구초대")
                        }
                        
                        Button {
                            logoutToggle.toggle()
                        } label: {
                            Text("로그아웃")
                        }
                        .alert("로그아웃", isPresented: $logoutToggle) {
                            Button("확인", role: .destructive) {
                                loginViewModel.signout()
                            }
                            Button("취소", role: .cancel) {}
                        } message: {
                            Text("로그아웃하시겠습니까?")
                        }
                        
                    }
                    .modifier(TextModifier(fontWeight: FontCustomWeight.normal, fontType: FontCustomType.body, color: FontCustomColor.color2))
                    Button {
                        if fireStoreViewModel.currentGame == nil {
                            deleteToggle.toggle()
                        } else {
                            // 게임중에는 탈퇴할 수 없습니다...
                        }
                    }
                label: {
                    Text("회원탈퇴")
                        .font(.custom("MaplestoryOTFLight", size: 15))
                        .foregroundColor(.red)
                }
                .sheet(isPresented: $deleteToggle) {
                    DeleteUserView(sheetToggle: $deleteToggle)
                        .interactiveDismissDisabled(true)
                }
                
//                .alert("회원탈퇴", isPresented: $deleteToggle) {
//                    TextField("",text: $text)
//                    Button("확인", role: .destructive) {
//                        if text == "탈퇴하겠습니다" {
//                            Task {
////                                await fireStoreViewModel.deleteUser()
//                                loginViewModel.deleteUser()
//                                deleteToggle.toggle()
//                            }
//                        }
//                    }
//                    Button("취소", role: .cancel) { deleteToggle.toggle() }
//                } message: {
//                    Text("탈퇴 시 개인정보는 30일이후 삭제됩니다. 탈퇴하시려면 \"탈퇴하겠습니다\"를 입력해주세요.")
//                }
                    
                    
                    VStack {
                        // 프레임 맞추려고 있는 VStack
                    }
                    .frame(height: g.size.height / 4)
                }
                .foregroundColor(Color("Color2"))
                .padding()
            }
            .onAppear{
                if loginViewModel.currentUserProfile != nil{
                    self.userProfile = loginViewModel.currentUserProfile
                }
                
            }
        }
    }
    private enum Coordinator {
        static func topViewController(
            _ viewController: UIViewController? = nil
        ) -> UIViewController? {
            
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows
            
            let vc = viewController ?? window?.first(where: { $0.isKeyWindow })?.rootViewController
            
            if let navigationController = vc as? UINavigationController {
                return topViewController(navigationController.topViewController)
            } else if let tabBarController = vc as? UITabBarController {
                return tabBarController.presentedViewController != nil ?
                topViewController(
                    tabBarController.presentedViewController
                ) : topViewController(
                    tabBarController.selectedViewController
                )
            } else if let presentedViewController = vc?.presentedViewController {
                return topViewController(presentedViewController)
            }
            return vc
        }
    }
    
    private enum Method: String {
        case share
        case link
    }
    
    private func buttonAction(_ stringToURL: String, _ method: Method) {
        let shareURL: URL = URL(string: stringToURL)!
        
        if method == .share {
            let activityViewController = UIActivityViewController(activityItems: [shareURL], applicationActivities: nil)
            let viewController = Coordinator.topViewController()
            activityViewController.popoverPresentationController?.sourceView = viewController?.view
            viewController?.present(activityViewController, animated: true, completion: nil)
        } else {
            UIApplication.shared.open(URL(string: stringToURL)!)
        }
    }
}

struct SettignView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(darkModeEnabled: .constant(false), notificationEnabled: .constant(true))
    }
}
