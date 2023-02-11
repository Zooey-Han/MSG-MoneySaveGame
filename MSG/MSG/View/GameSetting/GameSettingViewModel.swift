//
//  gameSettingViewModel.swift
//  MSG
//
//  Created by sehooon on 2023/01/17.
//

import SwiftUI
import Combine
import FirebaseFirestore
import Firebase
import FirebaseStorage
/*
 await fireStoreViewModel.addMultiGame(challenge)
 guard let myInfo = fireStoreViewModel.myInfo else { return }
 */

protocol FirestoreServiceInterface{
    func makeSingleGame(_ singleGame: Challenge) async
}

struct FirestoreService:FirestoreServiceInterface{
    let database = Firestore.firestore()
    typealias ChallengeUserData = [(user:(userName: String, userProfile: String), totalMoney: Int  )]

    init() { }
    
    // [UserRepo]
    // MARK: - 유저 정보를 불러오는 함수
    /// userId를 통해, 유저 정보를 가져온다.
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
        let userInfo = Msg(id: snapshot.documentID, nickName: nickName, profileImage: profileImage, game: game, gameHistory: gameHistory)
        return userInfo
    }
    // [ChallengeRepo]
    // MARK: - 싱글게임 추가 함수
    func addSingleGame(_ singleGame: Challenge) {
        print(#function)
        database.collection("Challenge").document(singleGame.id).setData([
            "id": singleGame.id,
            "gameTitle": singleGame.gameTitle,
            "limitMoney": singleGame.limitMoney,
            "startDate": singleGame.startDate,
            "endDate": singleGame.endDate,
            "inviteFriend": singleGame.inviteFriend
        ])
        
        //            self.newSingleGameId = singleGame.id
        //            singleGameList.append(singleGame)
    }
    // MARK: - User game에 String 추가하는 함수
    func updateUserGame(gameId: String) async {
        print(#function)
        guard let userId = Auth.auth().currentUser?.uid else{ return }
        do{
            try await database.collection("User").document(userId).updateData([ "game": gameId ])
            print("Game등록완료")
        }catch{
            print("미등록")
        }
    }
    // MARK: - SingleGame + User game에 String 추가하는 함수
    func makeSingleGame(_ singleGame: Challenge) async {
        print(#function)
        addSingleGame(singleGame)
        await updateUserGame(gameId: singleGame.id)
        //            currentGame = singleGame
    }
    // MARK: - User game에 Id값을 가져오는 함수
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
    // 한국어 패치된 현재 날짜
    func KoreanDateNow(date : Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        return dateFormatter.string(from: date)
    }
    
    
}


protocol ChallengeRepositoryInterface{
    func creatSingleChallenge(_ challenge: Challenge) async
    func creatMultiChallenge() async
}

struct ChallengeRepository: ChallengeRepositoryInterface{
    private let firestoreService: FirestoreServiceInterface
    
    init(firestoreService: FirestoreServiceInterface) {
        self.firestoreService = firestoreService
    }
    
    func creatSingleChallenge(_ challenge: Challenge)  async {
        await firestoreService.makeSingleGame(challenge)
    } // 싱글 챌린지 만들기
    func creatMultiChallenge() { } // 멀티 챌린지 만들기
    
    
}

protocol ChallengeUseCase{
    var repository: ChallengeRepositoryInterface { get }
    init(repository: ChallengeRepositoryInterface)
    func excuteMakeSingleChallenge(_ challenge: Challenge) async // 솔로 챌린지 생성
    func excuteMakeMultiChallenge(_ challenge: Challenge) async // 멀티 챌린지 생성
}

struct DefaultChallengeUseCase: ChallengeUseCase{
    //[Property]
    var repository: ChallengeRepositoryInterface
    
    //[init]
    init(repository: ChallengeRepositoryInterface) { self.repository = repository }
    
    //[method]
    func excuteMakeSingleChallenge(_ challenge: Challenge)  async {
        await repository.creatSingleChallenge(challenge)
    }
    func excuteMakeMultiChallenge(_ challenge: Challenge) async { }
}

// View Button Click 또는 액션
protocol GameSettingViewModelInput{
    func resetInputData() //
    func createSingleChallenge() async // 싱글 챌린지 생성
    
}

// View에 바인딩 되는 요소
protocol GameSettingViewModelOutput{
    var day:Double{ get }
    var title: String{ get }
    var targetMoney:String{ get }
    var startDate:Double{ get }
    var endDate:Double{ get }
    var isGameSettingValid:Bool{ get }
    var daySelection: Int{ get }
    var dayMultiArray:[Double]{ get }
    var dayArray:[String]{ get }
}

// View와 ViewModel 사이는 Combine으로 Data Binding 처리
final class GameSettingViewModel:ObservableObject, GameSettingViewModelInput, GameSettingViewModelOutput{
    //[property]
    let day:Double = 86400
    @Published var title = ""
    
    @Published var targetMoney = ""{
        didSet{
            if self.targetMoney.count > 7{
                targetMoney = String(targetMoney.prefix(7))
            }
        }
    }
    @Published var startDate:Double = Date().timeIntervalSince1970
    @Published var endDate:Double = Date().timeIntervalSince1970
    @Published var isGameSettingValid = false
    @Published var daySelection: Int = 5
    @Published var dayMultiArray:[Double] = [1,7,10,30,100]
    @Published var dayArray = ["1일", "7일", "10일", "30일", "100일"]
    private var publishers = Set<AnyCancellable>()
    private let challengeUseCase: ChallengeUseCase?
    
    //[init]
    init(challegeUsecase: ChallengeUseCase? = nil){
        self.challengeUseCase = challegeUsecase
        
        isGameSettingValidPublisher.receive(on: RunLoop.main)
            .assign(to: \.isGameSettingValid, on:self)
            .store(in: &publishers)
    }
    
    //[method]
    // 싱글게임생성
    func createSingleChallenge() async {
        let challenge = Challenge(id: UUID().uuidString, gameTitle: title, limitMoney: Int(targetMoney)!,
                                  startDate: String(startDate), endDate: String(endDate), inviteFriend: [], waitingFriend: [])
        await challengeUseCase?.excuteMakeSingleChallenge(challenge)
        resetInputData()
    }

}

extension GameSettingViewModel{
    func resetInputData (){
        DispatchQueue.main.async {
            self.title = ""
            self.targetMoney = ""
            self.startDate = Date().timeIntervalSince1970
            self.endDate  = self.startDate + 86400
            self.isGameSettingValid = false
        }
        
    }
    

    
    var isTitleValidPublisher: AnyPublisher<Bool,Never>{
        $title
            .map{ name in
                return name.trimSpacingCount >= 1
            }
            .eraseToAnyPublisher()
    }
    
    var isTargetMoneyValidPublisher: AnyPublisher<Bool,Never>{
        $targetMoney
            .map{ money in
                return money.trimSpacingCount >= 1 && Int(money) != nil
            }
            .eraseToAnyPublisher()
       
    }
    
    var isDaySelectionValidPublisher: AnyPublisher<Bool,Never>{
        $daySelection
            .map{ day in
                return day != 5
            }
            .eraseToAnyPublisher()
        
    }
    
    var isGameSettingValidPublisher: AnyPublisher<Bool,Never>{
        Publishers.CombineLatest3(isTitleValidPublisher, isTargetMoneyValidPublisher, isDaySelectionValidPublisher).map{ title, targetMoney, day in
            return title && targetMoney && day
        }
        .eraseToAnyPublisher()
    }
}
