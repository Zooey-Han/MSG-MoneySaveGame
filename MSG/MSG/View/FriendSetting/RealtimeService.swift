//
//  RealtimeService.swift
//  MSG
//
//  Created by 김민호 on 2023/02/13.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

struct RealtimeService {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private var friendRequestReference: DatabaseReference? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil}
        let ref = Database.database()
            .reference()
            .child("Friend")
            .child(uid)
        return ref
    }
    
    func friendListener(){
//        print(#function)
//        var user: [Msg] = []
//        var friendCount: Int = 0
//        guard let friendRequestReference else {
//            print("guard문으로 리턴됨")
//            return
//        }
//        friendRequestReference
//            .observe(.childAdded) { [weak self] snapshot,_  in
//                guard
//                    let self = self,
//                    var json = snapshot.value as? [String:Any]
//                else {
//                    print("나가짐")
//                    return
//                }
//                
//                print("Add Observe:",json)
//                json["id"] = snapshot.key
//                do {
//                    let postitData = try JSONSerialization.data(withJSONObject: json)
//                    print("add postitData:",postitData)
//                    let postit = try self.decoder.decode(Msg.self, from: postitData)
//                    print("받음:",postit)
//                    user.insert(postit, at: 0)
//                    user = Array(Set(self.user))
//                    self.friendCount = self.user.count
//                } catch {
//                    print("AddError")
//                    print("an error occurred", error)
//                }
//        }
//        
//        friendRequestReference
//            .observe(.childChanged) { [weak self] snapshot,_ in
//                guard
//                    let self = self,
//                    var json = snapshot.value as? [String:Any]
//                else {
//                    return
//                }
//                print("Changed Observe:",json)
//                json["id"] = snapshot.key
//                
//                do {
//                    let postitData = try JSONSerialization.data(withJSONObject: json)
//                    print("change의 do문:",postitData)
//                    let postit = try self.decoder.decode(Msg.self, from: postitData)
//                    print(postit)
//
//                    var index = 0
//                    for postitItem in self.user {
//                        if (postit.id == postitItem.id) {
//                            print(postitItem.id)
//                            self.user.remove(at: index)
//                        }
//                        index += 1
//                    }
//                    self.user.insert(postit, at: 0)
//                    self.friendCount = self.user.count
//                } catch {
//                    print("ChangeError")
//                    print("an error occurred", error)
//                }
//        }
//        
//        friendRequestReference
//            .observe(.childRemoved) {  [weak self] snapshot,_ in
//                guard
//                    let self = self,
//                    var json = snapshot.value as? [String: Any]
//                else {
//                    return
//                }
//                print("Delete Observe:",json)
//                json["id"] = snapshot.key
//                
//                do {
//                    let postitData = try JSONSerialization.data(withJSONObject: json)
//                    print("remove의 do문:",postitData)
//                    let postit = try self.decoder.decode(Msg.self, from: postitData)
//                    print(postit)
//                    
//                    var index = 0
//                    for postitItem in user {
//                        if (postit.id == postitItem.id) {
//                            print(postitItem.id)
//                            user.remove(at: index)
//                        }
//                        index += 1
//                    }
//                    self.friendCount = user.count
//                } catch {
//                    print("removeError")
//                    print("an error occurred", error)
//                }
//            }
//        return user
    }
}

extension RealtimeService: RealtimeListenerDataSource {

}
