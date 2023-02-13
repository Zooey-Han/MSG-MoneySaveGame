//
//  friendListenerUseCase.swift
//  MSG
//
//  Created by 김민호 on 2023/02/13.
//

import Foundation

protocol Listener {
    func friendListener()
}

struct FriendListenerUseCase: Listener {
    var repo: FriendListenerRepository
    func friendListener() {
        repo.friendListener()
    }
}
