//
//  AppDI.swift
//  MSG
//
//  Created by sehooon on 2023/02/10.
//

import Foundation

class AppDI {
    static let shared = AppDI()
    
    
    
    lazy var gameSettingViewModel: GameSettingViewModel = {
        let firestoreService = FirestoreService()
        let repository = ChallengeRepository(firestoreService: firestoreService)
        let challengeUseCase = DefaultChallengeUseCase(repository: repository )
        let viewModel = GameSettingViewModel(challegeUsecase: challengeUseCase)
        return viewModel
    }()
}
