//
//  FriendListenerRepository.swift
//  MSG
//
//  Created by 김민호 on 2023/02/13.
//

import Foundation

//MARK: - Repository protocol
//UseCase와 Repository 사이의 매개체 역할을 담당하는 프로토콜
protocol FriendListenerRepository {
    func friendListener()
}
