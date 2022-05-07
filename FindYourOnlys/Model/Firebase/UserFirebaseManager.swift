//
//  UserManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import Firebase
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import CoreMedia

class UserFirebaseManager {
    
    static let shared = UserFirebaseManager()
    
    let db = Firestore.firestore()
    
    // Unhashed nonce.
    var currentNonce: String?
    
    var initialUser = Auth.auth().currentUser
        
    var currentUser: User? {
        
        didSet {
            
            NotificationCenter.default.post(name: .didSetCurrentUser, object: nil)
        }
    }
    
    // Sign in with Apple
    func createAppleIdRequest() -> ASAuthorizationAppleIDRequest {
        
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIdProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        
        request.nonce = sha256(nonce)
        
        currentNonce = nonce
        
        return request
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        
        precondition(length > 0)
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        var result = ""
        
        var remainingLength = length
        
        while remainingLength > 0 {
            
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                
                var random: UInt8 = 0
                
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                
                if errorCode != errSecSuccess {
                    
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                
                if remainingLength == 0 {
                    
                    return
                }
                
                if random < charset.count {
                    
                    result.append(charset[Int(random)])
                    
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // Sign in with Apple
    func didCompleteWithAuthorization(with authorization: ASAuthorization, completion: @escaping (Result<String, Error>) -> Void) {
        
        if
            let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard
                let nonce = currentNonce
                    
            else {
                
                print("Error, a login callback was recevie, but no request was sent.")
                
                completion(.failure(AuthError.appleTokenError))
                
                return
            }
            
            guard
                let appleIdToken = appleIdCredential.identityToken
                    
            else {
                print("Can't fetch identity token.")
                
                completion(.failure(AuthError.appleTokenError))
                
                return
            }
            
            guard
                let idTokenString = String(data: appleIdToken, encoding: .utf8)
                    
            else {
                print("Unable to encode appleIdToken: \(appleIdToken)")
                
                completion(.failure(AuthError.appleTokenError))
                
                return
            }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            Auth.auth().signIn(with: credential) { [weak self] authDataResult, error in
                
                guard
                    let user = authDataResult?.user,
                    let self = self
                        
                else {
                    
                    if
                        let error = error as NSError? {
                        
                        guard
                            let errorCode = AuthErrorCode(rawValue: error.code)
                                
                        else {
                            
                            completion(.failure(AuthError.unexpectedError))
                            
                            return
                        }
                        
                        switch errorCode {
                            
                        case .invalidEmail:
                            
                            completion(.failure(AuthError.invalidEmail))
                            
                            return
                            
                        case .wrongPassword:
                            
                            completion(.failure(AuthError.wrongPassword))
                            
                            return
                            
                        case .invalidCredential:
                            
                            completion(.failure(AuthError.invalidCredential))

                            return
                            
                        case .emailAlreadyInUse:
                            
                            completion(.failure(AuthError.emailAlreadyInUse))
                            
                            return
                            
                        default:
                            
                            completion(.failure(AuthError.unexpectedError))
                            
                            return
                        }
                    }
                    
                    completion(.failure(AuthError.unexpectedError))
                    
                    return
                }
                
                // Save User on firebase
                self.fetchUser { result in
            
                    switch result {
                        
                    case .success(let firestoreUsers):
                        
                        guard
                            !firestoreUsers.map({ $0.id }).contains(user.uid)
                        
                        else {
                            
                            for firestoreUser in firestoreUsers where firestoreUser.id == user.uid {
                                
                                UserFirebaseManager.shared.currentUser = firestoreUser
                                
                                break
                            }
                            
                            completion(.success("success"))
                            
                            return
                        }
                            
                        self.saveUser(with: user.displayName ?? "初來乍到", with: user.email ?? "", with: user.uid) { error in
                            
                            guard
                                error == nil
                            
                            else {
                                
                                completion(.failure(error!))
                                
                                return
                            }
                            
                            UserFirebaseManager.shared.currentUser = User(
                                id: user.uid,
                                nickName: user.displayName ?? "初來乍到",
                                email: user.email ?? "",
                                imageURLString: "",
                                friends: [],
                                blockedUsers: []
                            )
                            
                            completion(.success("success"))
                        }
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        
        let inputData = Data(input.utf8)
        
        let hashedData = SHA256.hash(data: inputData)
        
        let hashString = hashedData.compactMap {
            
            String(format: "%02x", $0)
            
        }.joined()
        
        return hashString
    }
    
    // Register with Firebase
    func register(with nickName: String, with email: String, with password: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authDataResult, error in
            
            guard
                error == nil,
                let user = authDataResult?.user,
                let self = self
            
            else {
                
                if
                    let error = error as NSError? {
                    
                    guard
                        let errorCode = AuthErrorCode(rawValue: error.code)
                            
                    else {
                        
                        completion(.failure(AuthError.unexpectedError))
                        
                        return
                    }
                    
                    switch errorCode {
                        
                    case .invalidEmail:
                        
                        completion(.failure(AuthError.invalidEmail))
                        
                        return
                        
                    case .weakPassword:
                        
                        completion(.failure(AuthError.weakPassword))

                        return
                        
                    case .emailAlreadyInUse:
                        
                        completion(.failure(AuthError.emailAlreadyInUse))
                        
                        return
                        
                    default:
                        
                        completion(.failure(AuthError.unexpectedError))
                        
                        return
                    }
                }
                
                completion(.failure(AuthError.unexpectedError))
                
                return
            }
            
            // Save User on firebase
            self.saveUser(with: nickName, with: email, with: user.uid) { error in
                
                if
                    let error = error {
                    
                    completion(.failure(error))
                    
                } else {
                    
                    completion(.success(user.uid))
                }
            }
        }
    }
    
    // Sign in with Firebase
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Result<String, Error>) -> Void ){
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            guard
                error == nil,
                let userId = authDataResult?.user.uid
            
            else {
                
                if
                    let error = error as NSError? {
                    
                    guard
                        let errorCode = AuthErrorCode(rawValue: error.code)
                            
                    else {
                        
                        completion(.failure(AuthError.unexpectedError))
                        
                        return
                    }
                    
                    switch errorCode {
                        
                    case .invalidEmail:
                        
                        completion(.failure(AuthError.invalidEmail))
                        
                        return
                        
                    case .wrongPassword:
                        
                        completion(.failure(AuthError.wrongPassword))
                        
                        return
                        
                    case .userNotFound:
                        
                        completion(.failure(AuthError.authNotFound))
                        
                        return
                        
                    default:
                        
                        completion(.failure(AuthError.unexpectedError))
                        
                        return
                    }
                }
                
                completion(.failure(AuthError.unexpectedError))
                
                return
            }
            
            completion(.success(userId))
        }
        
    }
    
    // Sign out
    func signOut(completion: @escaping (Result<String, Error>) -> Void) {
        
        let firebaseAuth = Auth.auth()
        
        do {
            
            try firebaseAuth.signOut()
            
            completion(.success("success"))
            
        } catch {
            
            if
                let error = error as NSError? {
                
                guard
                    let errorCode = AuthErrorCode(rawValue: error.code)
                        
                else {
                    
                    completion(.failure(AuthError.unexpectedError))
                    
                    return
                }
                
                switch errorCode {
                    
                case .keychainError:
                    
                    completion(.failure(AuthError.keychainError))
                    
                    return
                    
                default:
                    
                    completion(.failure(AuthError.unexpectedError))
                    
                    return
                }
            }
            
            completion(.failure(AuthError.unexpectedError))
            
            return
        }
    }
    
    // Delete User
    func deleteAuthUser(completion: @escaping (Error?) -> Void) {
        
        guard
            let user = Auth.auth().currentUser
                
        else {
            
            return
        }
        
        let group = DispatchGroup()
        
        DispatchQueue.global().async {
            
            // Favorite pet
            group.enter()
            FavoritePetFirebaseManager.shared.removeFavoritePet(with: user.uid) { error in
                
                guard
                    error == nil
                        
                else {
                    
                    completion(DeleteDataError.deleteFavoritePetError)
                    
                    group.leave()
                    
                    return
                }
                group.leave()
            }
            
            // FriendRequest
            group.enter()
            ProfileFirebaseManager.shared.removeFriendRequest(with: user.uid) { error in
                
                guard
                    error == nil
                        
                else {
                    
                    completion(DeleteDataError.deleteFriendRequestError)
                    
                    group.leave()
                    
                    return
                }
                group.leave()
            }
            
            // Article
            group.enter()
            PetSocietyFirebaseManager.shared.deleteArticle(with: user.uid) { error in
                
                guard
                    error == nil
                        
                else {
                    
                    completion(DeleteDataError.deleteArticleError)
                    
                    group.leave()
                    
                    return
                }
                group.leave()
            }
            
            // ChatRoom
            group.enter()
            PetSocietyFirebaseManager.shared.deleteChatRoom(with: user.uid) { error in
                
                guard
                    error == nil
                        
                else {
                    
                    completion(DeleteDataError.deleteChatRoomError)
                    
                    group.leave()
                    
                    return
                }
                group.leave()
            }
            
            // Message
            group.enter()
            PetSocietyFirebaseManager.shared.deleteMessage(with: user.uid) { error in
                
                guard
                    error == nil
                        
                else {
                    
                    completion(DeleteDataError.deleteChatRoomError)
                    
                    group.leave()
                    
                    return
                }
                group.leave()
            }
            
            //Friend
            group.enter()
            PetSocietyFirebaseManager.shared.deleteFriend(withCurrent: user.uid) { error in
                
                guard
                    error == nil
                        
                else {
                    
                    completion(DeleteDataError.deleteFriendError)
                    
                    group.leave()
                    
                    return
                }
                group.leave()
            }
            
            // Need all delete process finish to end the delete process.
            group.notify(queue: DispatchQueue.global()) {
                
                let semaphore = DispatchSemaphore(value: 0)
                
                // Account
                user.delete { error in
                    
                    guard
                        error == nil
                            
                    else {
                        
                        if
                            let error = error as NSError? {
                            
                            guard
                                let errorCode = AuthErrorCode(rawValue: error.code)
                                    
                            else {
                                
                                completion(DeleteAccountError.unexpectedError)
                                
                                return
                            }
                            
                            switch errorCode {
                                
                            case .requiresRecentLogin:
                                
                                completion(DeleteAccountError.deleteUserAccountError)
                                
                                return
                                
                            default:
                                
                                completion(DeleteAccountError.unexpectedError)
                                
                                return
                            }
                        }
                        
                        completion(DeleteAccountError.unexpectedError)
                        
                        return
                    }
                    
                    semaphore.signal()
                }
                
                semaphore.wait()
                // User
                self.deleteUser(with: user.uid) { error in
                    
                    guard
                        error == nil
                            
                    else {
                              
                        completion(DeleteDataError.deleteUserError)
                        
                        return
                    }
                    
                    completion(nil)
                }
            }
        }
    }
    
    func deleteUser(with userId: String, completion: @escaping (Error?) -> Void) {
        
        db.collection(FirebaseCollectionType.user.rawValue).document(userId).delete() { error in
            
            guard
                error == nil
                    
            else {
                
                completion(error)
                
                return
            }
            
            completion(nil)
        }
    }
    
    func fetchUser(completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.user.rawValue)
            .addSnapshotListener { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var users = [User]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let user = try document.data(as: User.self)
                        
                        users.append(user)
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(users))
            }
    }
    
    func fetchUser(with userEmail: String, completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection(FirebaseCollectionType.user.rawValue)
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                
                guard
                    let snapshot = snapshot else { return }
                
                var users = [User]()
                
                for document in snapshot.documents {
                    
                    do {
                        
                        let user = try document.data(as: User.self)
                        
                        users.append(user)
                    } catch {
                        
                        completion(.failure(error))
                    }
                }
                
                completion(.success(users))
            }
    }
    
    func blockUser(with userId: String, completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = currentUser else { return }
        
        db
            .collection(FirebaseCollectionType.user.rawValue)
            .document(currentUser.id)
            .updateData([FirebaseFieldType.blockedUsers.rawValue: FieldValue.arrayUnion([userId])])
    }
    
    func saveUser(with nickName: String, with email: String, with id: String, completion: @escaping (Error?) -> Void) {
        
        let documentReference = db.collection(FirebaseCollectionType.user.rawValue).document("\(id)")
        
        do {
            
            let user = User(
                id: id,
                nickName: nickName,
                email: email,
                imageURLString: "",
                friends: [],
                blockedUsers: []
            )
            
            try documentReference.setData(from: user, encoder: Firestore.Encoder())
            
            completion(nil)
            
        } catch {
            
            completion(error)
        }
    }
    
    func saveUser(withUser user: User, completion: @escaping (Result<String, Error>) -> Void) {
        
        let documentReference = db.collection(FirebaseCollectionType.user.rawValue).document("\(user.id)")
        
        do {
            
            try documentReference.setData(from: user)
            
            completion(.success("success"))
            
        } catch {
            
            completion(.failure(error))
        }
    }
    
    // MARK: - Convert functions
    private func convertUserToViewModels(from users: [User]) -> [UserViewModel] {
        
        var viewModels = [UserViewModel]()
        
        for user in users {
            
            let viewModel = UserViewModel(model: user)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    func setUsers(with viewModels: Box<[UserViewModel]>, users: [User]) {
        
        viewModels.value = UserFirebaseManager.shared.convertUserToViewModels(from: users)
    }
}
