//
//  AuthError.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/7.
//

import Foundation

enum AuthError: Error {
    
    case invalidEmail
    
    case wrongPassword
    
    case invalidCredential
    
    case emailAlreadyInUse
    
    case weakPassword
    
    case keychainError
    
    case appleTokenError
    
    case authNotFound
    
    case unexpectedError
    
    var errorMessage: String {
        
        switch self {
        case .invalidEmail:
            
            return "信箱格式錯誤，請重新輸入"
            
        case .wrongPassword:
            
            return "密碼錯誤，請重新輸入"
            
        case .invalidCredential:
            
            return "驗證失敗，請重新輸入"
            
        case .emailAlreadyInUse:
            
            return "該信箱已被使用，請更換信箱"
            
        case .weakPassword:
            
            return "密碼請輸入至少6碼"
            
        case .keychainError:
            
            return "登出失敗，請再嘗試一次"
            
        case .appleTokenError:
            
            return "Apple 憑證異常，請再嘗試一次或使用其他登入方式"
            
        case .authNotFound:
            
            return "不存在使用者信箱，請重新輸入"
            
        case .unexpectedError:
            
            return "發生預期外的錯誤，請重新輸入"
        }
    }
}

enum DeleteDataError: Error {
    
    case deleteUserError
    
    case deleteArticleError
    
    case deleteFriendRequestError
    
    case deleteChatRoomError
    
    case deleteFavoritePetError
    
    case deleteMessageError
    
    case deleteFriendError
    
    var errorMessage: String {
        
        switch self {
            
        case .deleteUserError:
            
            return "刪除使用者資料失敗，請再嘗試一次"
            
        case .deleteArticleError:
            
            return "刪除使用者文章失敗，請再嘗試一次"
            
        case .deleteFriendRequestError:
            
            return "刪除使用者好友邀請失敗，請再嘗試一次"
            
        case .deleteChatRoomError:
            
            return "刪除使用者聊天室失敗，請再嘗試一次"
            
        case .deleteFavoritePetError:
            
            return "刪除使用者收藏寵物失敗，請再嘗試一次"
            
        case .deleteMessageError:
            
            return "刪除使用者聊天訊息失敗，請再嘗試一次"
            
        case .deleteFriendError:
            
            return "刪除使用者好友失敗，請再嘗試一次"
        }
    }
}

enum DeleteAccountError: Error {
    
    case deleteUserAccountError
    
    case unexpectedError
    
    var errorMessage: String {
        
        switch self {
            
        case .deleteUserAccountError:
            
            return "刪除使用者帳號失敗，請重新登入後再嘗試一次"
            
        case .unexpectedError:
            
            return "刪除使用者帳號發生預期外的錯誤，請再嘗試一次"
        }
    }
}
