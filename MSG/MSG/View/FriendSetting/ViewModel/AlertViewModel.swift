//
//  AlertViewModel.swift
//  MSG
//
//  Created by 김민호 on 2023/02/13.
//

import Foundation

protocol AlertInput {
    func friendListener()
}
    

protocol AlertOutput {}


class AlertViewModel: ObservableObject, AlertInput {
    
    func friendListener() {
        
    }
}
