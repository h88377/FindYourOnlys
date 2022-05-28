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
    
    let database = Firestore.firestore()
    
    var initialUser = Auth.auth().currentUser
        
    var currentUser: User? {
        
        didSet {
            
            NotificationCenter.default.post(name: .didSetCurrentUser, object: nil)
        }
    }
    
    // Unhashed nonce.
    var currentNonce: String?
    
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
    
    // Sign in with Apple
    func didCompleteWithAuthorization(
        with authorization: ASAuthorization,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        if
            let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            guard
                let nonce = currentNonce,
                let appleIdToken = appleIdCredential.identityToken,
                let idTokenString = String(data: appleIdToken, encoding: .utf8)
                
            else {
                
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
                    let authDataResult = authDataResult,
                    let self = self
                        
                else {
                    
                    if
                        let error = error as NSError?,
                        let errorCode = AuthErrorCode(rawValue: error.code) {
                        
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
                        
                    } else {
                        
                        completion(.failure(AuthError.unexpectedError))
                        
                        return
                    }
                }
                
                self.saveUserOnFirebase(withAuth: authDataResult) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        completion(.success(()))
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private func saveUserOnFirebase(
        withAuth authDataResult: AuthDataResult,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let user = authDataResult.user
        
        fetchUser { result in
    
            switch result {
                
            case .success(let firestoreUsers):
                
                let isExistUser = firestoreUsers.map({ $0.id }).contains(user.uid)
                
                guard
                    !isExistUser
                
                else {
                    
                    for firestoreUser in firestoreUsers where firestoreUser.id == user.uid {
                        
                        UserFirebaseManager.shared.currentUser = firestoreUser
                        
                        break
                    }
                    
                    completion(.success(()))
                    
                    return
                }
                    
                self.saveUser(
                    with: user.displayName ?? "初來乍到",
                    with: user.email ?? "",
                    with: user.uid
                ) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        UserFirebaseManager.shared.currentUser = User(
                            id: user.uid,
                            nickName: user.displayName ?? "初來乍到",
                            email: user.email ?? "",
                            imageURLString: "",
                            friends: [],
                            blockedUsers: []
                        )
                        
                        completion(.success(()))
                        
                    case .failure(let error):
                        
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
    
    // Register with Firebase
    func register(
        with nickName: String,
        with email: String,
        with password: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authDataResult, error in
            
            guard
                error == nil,
                let user = authDataResult?.user,
                let self = self
            
            else {
                
                if
                    let error = error as NSError?,
                    let errorCode = AuthErrorCode(rawValue: error.code) {
                    
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
                    
                } else {
                    
                    completion(.failure(AuthError.unexpectedError))
                    
                    return
                }
            }
            
            // Save User on firebase
            self.saveUser(with: nickName, with: email, with: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    completion(.success(user.uid))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Sign in with Firebase
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Result<String, Error>) -> Void ) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            
            guard
                error == nil,
                let userId = authDataResult?.user.uid
            
            else {
                
                if
                    let error = error as NSError?,
                    let errorCode = AuthErrorCode(rawValue: error.code) {
                    
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
                    
                } else {
                    
                    completion(.failure(AuthError.unexpectedError))
                    
                    return
                }
            }
            
            completion(.success(userId))
        }
    }
    
    // Sign out
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        
        do {
            
            try Auth.auth().signOut()
            
            completion(.success(()))
            
        } catch {
            
            if
                let error = error as NSError?,
                let errorCode = AuthErrorCode(rawValue: error.code) {
                
                switch errorCode {
                    
                case .keychainError:
                    
                    completion(.failure(AuthError.keychainError))
                    
                    return
                    
                default:
                    
                    completion(.failure(AuthError.unexpectedError))
                    
                    return
                }
                
            } else {
                
                completion(.failure(AuthError.unexpectedError))
                
                return
            }
        }
    }
    
    // Delete User
    func deleteAuthUser(completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard
            let user = Auth.auth().currentUser
                
        else {
            
            return
        }
        
        let group = DispatchGroup()
        
        DispatchQueue.global().async {
            
            // Favorite pet
            group.enter()
            FavoritePetFirebaseManager.shared.removeFavoritePet(with: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    group.leave()
                    
                case .failure:
                    
                    completion(.failure(DeleteDataError.deleteFavoritePetError))
                    
                    group.leave()
                }
            }
            
            // FriendRequest
            group.enter()
            ProfileFirebaseManager.shared.removeFriendRequest(with: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    group.leave()
                    
                case .failure:
                    
                    completion(.failure(DeleteDataError.deleteFriendRequestError))
                    
                    group.leave()
                }
            }
            
            // Article
            group.enter()
            PetSocietyFirebaseManager.shared.deleteArticle(with: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    group.leave()
                    
                case .failure:
                    
                    completion(.failure(DeleteDataError.deleteArticleError))
                    
                    group.leave()
                }
            }
            
            // ChatRoom
            group.enter()
            PetSocietyFirebaseManager.shared.deleteChatRoom(with: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    group.leave()
                    
                case .failure:
                    
                    completion(.failure(DeleteDataError.deleteChatRoomError))
                    
                    group.leave()
                }
            }
            
            // Message
            group.enter()
            PetSocietyFirebaseManager.shared.deleteMessage(with: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    group.leave()
                    
                case .failure:
                    
                    completion(.failure(DeleteDataError.deleteMessageError))
                    
                    group.leave()
                }
            }
            
            // Friend
            group.enter()
            PetSocietyFirebaseManager.shared.deleteFriend(withCurrent: user.uid) { result in
                
                switch result {
                    
                case .success:
                    
                    group.leave()
                    
                case .failure:
                    
                    completion(.failure(DeleteDataError.deleteFriendError))
                    
                    group.leave()
                }
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
                            let error = error as NSError?,
                            let errorCode = AuthErrorCode(rawValue: error.code) {
                            
                            switch errorCode {
                                
                            case .requiresRecentLogin:
                                
                                completion(.failure(DeleteAccountError.deleteUserAccountError))
                                
                                return
                                
                            default:
                                
                                completion(.failure(DeleteAccountError.unexpectedError))
                                
                                return
                            }
                            
                        } else {
                            
                            completion(.failure(DeleteAccountError.unexpectedError))
                            
                            return
                        }
                    }
                    
                    semaphore.signal()
                }
                
                semaphore.wait()
                // User
                self.deleteUser(with: user.uid) { result in
                    
                    switch result {
                        
                    case .success:
                        
                        completion(.success(()))
                        
                    case .failure:
                        
                        completion(.failure(DeleteDataError.deleteUserError))
                    }
                }
            }
        }
    }
    
    func deleteUser(with userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        database.collection(FirebaseCollectionType.user.rawValue).document(userId).delete { error in
            
            guard
                error == nil
                    
            else {
                
                completion(.failure(FirebaseError.deleteUserError))
                
                return
            }
            
            completion(.success(()))
        }
    }
    
    func fetchUser(completion: @escaping (Result<[User], Error>) -> Void) {
        
        database
            .collection(FirebaseCollectionType.user.rawValue)
            .addSnapshotListener { snapshot, _ in
                
                guard
                    let snapshot = snapshot
                
                else {
                        completion(.failure(FirebaseError.fetchUserError))
                        
                        return
                    }
                
                do {
                    
                    let users = try snapshot.documents.map { try $0.data(as: User.self)}
                    
                    completion(.success(users))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodeUserError))
                }
            }
    }
    
    func fetchUser(with userEmail: String, completion: @escaping (Result<[User], Error>) -> Void) {
        
        database
            .collection(FirebaseCollectionType.user.rawValue)
            .whereField(FirebaseFieldType.email.rawValue, isEqualTo: userEmail)
            .getDocuments { snapshot, _ in
                
                guard
                    let snapshot = snapshot else {
                        
                        completion(.failure(FirebaseError.fetchUserError))
                        
                        return
                    }
                
                do {
                    
                    let users = try snapshot.documents.map { try $0.data(as: User.self)}
                    
                    completion(.success(users))
                    
                } catch {
                    
                    completion(.failure(FirebaseError.decodeUserError))
                }
            }
    }
    
    func blockUser(with userId: String) {
        
        guard
            let currentUser = currentUser else { return }
        
        database
            .collection(FirebaseCollectionType.user.rawValue)
            .document(currentUser.id)
            .updateData([FirebaseFieldType.blockedUsers.rawValue: FieldValue.arrayUnion([userId])])
    }
    
    func saveUser(
        with nickName: String,
        with email: String,
        with id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        let documentReference = database.collection(FirebaseCollectionType.user.rawValue).document("\(id)")
        
        do {
            
            let user = User(
                id: id,
                nickName: nickName,
                email: email,
                imageURLString: "",
                friends: [],
                blockedUsers: []
            )
            
            try documentReference.setData(from: user)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.createUserError))
        }
    }
    
    func saveUser(withUser user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        
        let documentReference = database.collection(FirebaseCollectionType.user.rawValue).document("\(user.id)")
        
        do {
            
            try documentReference.setData(from: user)
            
            completion(.success(()))
            
        } catch {
            
            completion(.failure(FirebaseError.updateUserError))
        }
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
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        
        let inputData = Data(input.utf8)
        
        let hashedData = SHA256.hash(data: inputData)
        
        let hashString = hashedData.compactMap {
            
            String(format: "%02x", $0)
            
        }.joined()
        
        return hashString
    }
    
    // MARK: - Convert functions
    
    func setUsers(with viewModels: Box<[UserViewModel]>, users: [User]) {
        
        viewModels.value = users.map { UserViewModel(model: $0) }
    }
}
