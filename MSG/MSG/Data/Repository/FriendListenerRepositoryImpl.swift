//
//  FriendListenerRepositoryImpl.swift
//  MSG
//
//  Created by 김민호 on 2023/02/13.
//

import Foundation

struct FriendListenerRepositoryImpl: FriendListenerRepository {
    var dataSource: RealtimeListenerDataSource
    
    func friendListener() {
        dataSource.friendListener()
    }
    
}
