//
//  FirestoreDataSource.swift
//  MSG
//
//  Created by sehooon on 2023/02/13.
//

import Combine
import Foundation
import FirebaseFirestore
import FirebaseAuth



//MARK: - API
// 실제 데이터를 받아오는 위치
struct FirebaseService {
    var database: Firestore = Firestore.firestore()
    
    func findSearchUser(text: String) -> [Msg] {
        print(#function)
        var searchUserArray: [Msg] = []
        database
            .collection("User")
            .getDocuments { (snapshot, error) in
                if let snapshot {
                    for document in snapshot.documents {
                        let id: String = document.documentID
                        let docData = document.data()
                        let nickName: String = docData["nickName"] as? String ?? ""
                        let profileImage: String = docData["profileImage"] as? String ?? ""
                        let game: String = docData["game"] as? String ?? ""
                        let gameHistory: [String] = docData["gameHistory"] as? [String] ?? []
                        let getUser: Msg = Msg(id: id, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
                        if (nickName.contains(text.lowercased()) || nickName.contains( text.uppercased())) && (id != Auth.auth().currentUser?.uid) {
                            
                            searchUserArray.append(getUser)
                        }
                    }
                    
                }
            }
        return searchUserArray
    }
    func findUser1(text: [Msg]) async -> [Msg]{
//        print(#function)
//        print("input Value:",text)
        //        notGamePlayFriend.removeAll()
        var notGamePlayFriend: [Msg] = []
        do {
            let data = try await database.collection("User").getDocuments()
            for document in data.documents {
                let id: String = document.documentID
                let docData = document.data()
                let nickName: String = docData["nickName"] as? String ?? ""
                let profileImage: String = docData["profileImage"] as? String ?? ""
                let game: String = docData["game"] as? String ?? ""
                let gameHistory: [String] = docData["gameHistory"] as? [String] ?? []
                let getUser: Msg = Msg(id: id, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
                for i in text {
                    if i.id == id && game.isEmpty {
                        notGamePlayFriend.append(getUser)
                    }
                }
                notGamePlayFriend = Array(Set(notGamePlayFriend))
            }
            //            print("스토어에서 데이터:",notGamePlayFriend)
            return notGamePlayFriend
        } catch {
            print("error!")
            return []
        }
    }
    @MainActor
    func findFriend() async throws -> ([Msg],[String]){
//        print("Impl",#function)
        var friendIdArray: [String] = []
        var friendArray: [Msg] = []
        //            self.myFrinedArray.removeAll()
        //            self.friendIdArray.removeAll()
        guard let userId = Auth.auth().currentUser?.uid else{ return ([],[])  }
        // 유저 컬렉션 -> 프렌드컬렉션 ->  친구들 최신화가 안된 친구들, 즉 게임중인지 모름.
        let snapshot = try await database.collection("User").document(userId).collection("friend").getDocuments()
        for document in snapshot.documents{
            //func fetchUserInfo()
            
            let id: String = document.documentID
            let docData = document.data()
            let nickName: String = docData["nickName"] as? String ?? ""
            let profileImage: String = docData["profileImage"] as? String ?? ""
            let game: String = docData["game"] as? String ?? ""
            let gameHistory: [String] = docData["gameHistory"] as? [String] ?? []
            let getUser: Msg = Msg(id: id, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
//            if !friend.contains(getUser){friendArray.append(getUser) }
            friendArray.append(getUser)
            friendIdArray.append(id)
        }
        return (friendArray,friendIdArray)
    }
    
    func searchUser(text: String) -> [Msg]{
//        print(#function)
        var searchUserArray: [Msg] = []
        database
            .collection("User")
            .getDocuments { (snapshot, error) in
                if let snapshot {
                    for document in snapshot.documents {
                        let id: String = document.documentID
                        let docData = document.data()
                        let nickName: String = docData["nickName"] as? String ?? ""
                        let profileImage: String = docData["profileImage"] as? String ?? ""
                        let game: String = docData["game"] as? String ?? ""
                        let gameHistory: [String] = docData["gameHistory"] as? [String] ?? []
                        let getUser: Msg = Msg(id: id, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
                        if (nickName.contains(text.lowercased()) || nickName.contains( text.uppercased())) && (id != Auth.auth().currentUser?.uid) {
                            
                            searchUserArray.append(getUser)
                        }
                    }
                    
                }
            }
        return searchUserArray
    }
    
    
}

//

extension FirebaseService: FriendDataSource {

}

extension FirebaseService: ChallengeDataSource{
    

    // MARK: - User game에 gameId를 업데이트 하는 메서드
    func updateUserGame(gameId: String) async {
        print(#function)
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        do{
            try await database.collection("User").document(userId).updateData([ "game": gameId ])
        }catch{
            print("Error #UPDATE USER GAME")
        }
    }
    
    // MARK: - SingleGame + User game에 String 추가하는 함수
    func makeSingleGame(_ singleGame: Challenge) async {
        print(#function)
        do{
            try await database.collection("Challenge").document(singleGame.id).setData([
                "id": singleGame.id,
                "gameTitle": singleGame.gameTitle,
                "limitMoney": singleGame.limitMoney,
                "startDate": singleGame.startDate,
                "endDate": singleGame.endDate,
                "inviteFriend": singleGame.inviteFriend
            ])
            await updateUserGame(gameId: singleGame.id)
        }catch{ print("Error #MAKE SINGLE GAME") }
    }
    
    // MARK: - 현재 진행중인 User의 Challenge ID를 가져오는 함수
    func fetchChallengeId() async -> String? {
        print(#function)
        guard let userId = Auth.auth().currentUser?.uid else{ return nil }
        let ref = database.collection("User").document(userId)
        do {
            let snapShot = try await ref.getDocument()
            guard let docData = snapShot.data() else { return nil }
            let gameId = docData["game"] as? String ?? ""
            return gameId
        } catch {
            print("catched")
            return nil
        }
    }
}

//MARK: - AddFriendDataSource
extension FirebaseService: AddFriendDataSource {
    func myInfo() async throws -> Msg? {
        guard let myId = Auth.auth().currentUser?.uid else { return nil }
        let ref = Firestore.firestore().collection("User").document(myId)
        let snapshot = try await ref.getDocument()
        guard let docData = snapshot.data() else { return nil }
        let nickName = docData["nickName"] as? String ?? ""
        let profileImage = docData["profileImage"] as? String ?? ""
        let game = docData["game"] as? String ?? ""
        let gameHistory = docData["gameHistory"] as? [String] ?? []
        let userInfo = Msg(id: snapshot.documentID, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
        return userInfo
    }
    
    // MARK: 친구추가
    /// 둘다 친구를 추가합니다.
    func addBothWithFriend(user: Msg, me: Msg) {
        print(#function)
        
        //나에게 친구를 추가합니다.
        database.collection("User")
            .document(Auth.auth().currentUser?.uid ?? "")
            .collection("friend")
            .document(user.id)
            .setData(["id": user.id,
                      "nickName": user.nickName,
                      "profileImage": user.profileImage,
                      "game": user.game,
                      "gameHistory": user.gameHistory ?? []
                     ])
        
        //친구에게 나를 추가합니다.
        database.collection("User")
            .document(user.id)
            .collection("friend")
            .document(Auth.auth().currentUser?.uid ?? "")
            .setData(["id": me.id,
                      "nickName": me.nickName,
                      "profileImage": me.profileImage,
                      "game": me.game,
                      "gameHistory": me.gameHistory ?? []
                     ])
    }
    
    // MARK:  친구 초대 수락 시, WaitingCollection에서 해당 유저 제거
    func deleteWaitingFriend(userId: String) async {
        print(#function)
        guard let myId = Auth.auth().currentUser?.uid else { return }
        guard var waitingFriend = await fetchWaitingFriend(userId) else { return }
        guard let index = waitingFriend.firstIndex(of: myId) else { return }
        waitingFriend.remove(at: index)
        do{
            try await database.collection("Waiting").document(userId).updateData([ "sendToFriend" : waitingFriend ])
        }catch{
                print("Error")
        }
    }
    // MARK:  waitingFriend가져오기
    func fetchWaitingFriend(_ userId: String) async -> [String]? {
        print(#function)
        do{
            let document = try await database.collection("Waiting").document(userId).getDocument()
            guard let docData = document.data() else{ return nil }
            let waitingArr = docData["sendToFriend"] as? [String] ?? []
            return waitingArr
        }catch{
            print("Error!")
            return nil
        }
    }
    
}

extension FirebaseService: DivideFriendDataSource {
    // MARK: - 입력받은 친구목록 아이디들로 실제 프로필 받아오는 메서드.
    func makeProfile(_ userIdArray:[String]) async -> [Msg]? {
        var friendArray:[Msg] = []
        for friend in userIdArray{
            do{
                let user = try await fetchUserInfo(friend)
                if user != nil { friendArray.append(user!) }
            }catch{
                return nil
            }
        }
        return friendArray
    }
    
    // MARK: -
    func fetchUserInfo(_ userId: String) async throws -> Msg? {
        print(#function)
        guard (Auth.auth().currentUser != nil) else { return nil}
        let ref = database.collection("User").document(userId)
        let snapshot = try await ref.getDocument()
        guard let docData = snapshot.data() else { return nil }
        let nickName = docData["nickName"] as? String ?? ""
        let profileImage = docData["profileImage"] as? String ?? ""
        let game = docData["game"] as? String ?? ""
        let gameHistory = docData["gameHistory"] as? [String] ?? []
//        let friend = docData["friend"] as? [String] ?? []
        let userInfo = Msg(id: snapshot.documentID, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
        return userInfo
    }


    
    // MARK: - 모든 유저에서, 내가 입력한 닉네임의 유저찾기
    /// 검색할 유저 닉네임 입력 시, 해당 닉네임이 포함된 유저 목록 가져오는 메서드.
    @MainActor
    func findUser(text: String) async throws -> [String] {
//        print(#function)
//        self.searchUserArray.removeAll()
        var searchUserArray: [String] = []
        let snapShots = try await database.collection("User").getDocuments()
        for document in snapShots.documents{
            let id: String = document.documentID
            let docData = document.data()
            let nickName: String = docData["nickName"] as? String ?? ""
//            nickName.lowercased()
            if nickName.lowercased().contains(text.lowercased()) && id != Auth.auth().currentUser?.uid {
                searchUserArray.append(id)
            }
        }
        return searchUserArray
    }
    
    
    func findUser1(text: [Msg]) -> [Msg] {
//        print(#function)
//        notGamePlayFriend.removeAll()
        var notGamePlayFriend: [Msg] = []
        database
            .collection("User")
            .getDocuments { (snapshot, error) in
                if let snapshot {
                    for document in snapshot.documents {
                        let id: String = document.documentID
                        let docData = document.data()
                        let nickName: String = docData["nickName"] as? String ?? ""
                        let profileImage: String = docData["profileImage"] as? String ?? ""
                        let game: String = docData["game"] as? String ?? ""
                        let gameHistory: [String] = docData["gameHistory"] as? [String] ?? []
                        let getUser: Msg = Msg(id: id, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
                        for i in text {
                            if i.id == id && game.isEmpty {
                                notGamePlayFriend.append(getUser)
                            }
                        }
                    }
                    notGamePlayFriend = Array(Set(notGamePlayFriend))
                    
                }
            }
        return notGamePlayFriend
    }

    
    
    // MARK: - 친구 요청을 보낸 경우, 수락했는지 확인하는 리스너
//    func subscribe() -> [String]{
//        print(#function)
//        var listener: ListenerRegistration?
//        var sendToFriendArray: [String] = []
//        guard let uid = Auth.auth().currentUser?.uid else { return []}
//        let ref = database.collection("Waiting").document(uid)
//        listener = ref.addSnapshotListener { querySnapshot, error in
//            guard let document = querySnapshot  else { return }
//            guard let docData = document.data() else { return }
//            sendToFriendArray = docData["sendToFriend"] as? [String] ?? []
////            Task { try await self.findFriend() }
//            print("== check subscribe == :",sendToFriendArray)
////            print("외안되")
//        }
//        return sendToFriendArray
//    }
    
    
    // MARK: -  친구에게 친구초대 보낼 경우, sendToFriendArray에 해당 유저 넣기
    /// 친구가 친구수락을 받을때까지, sendToFriendArray에 친구 아이디 저장
    func uploadSendToFriend(_ userId: String, sendToFriendArray: [String]){
        print(#function)
//        var sendToFriendArray: [String] = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        database.collection("Waiting").document(uid).setData([ "sendToFriend": sendToFriendArray + [userId] ])
    }
}
//protocol AddFriendDataSource {
//    func myInfo() //f
//    func addUser() // f
//    func deleteWaitingFriend() // f
//}


