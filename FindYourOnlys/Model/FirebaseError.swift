//
//  FirebaseError.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/9.
//

import Foundation

enum FirebaseError: Error {
    
    case fetchPetError
    
    case decodePetError
    
    case updatePetError
    
    case fetchArticleError
    
    case updateArticleError
    
    case publishArticleError
    
    case decodeArticleError
    
    case deleteArticleError
    
    case uploadImageError
    
    case encodeImageError
    
    case fetchImageURLError
    
    case leaveCommentError
    
    case toggleLikeArticleError
    
    case fetchChatRoomError
    
    case deleteChatRoomError
    
    case fetchMessageError
    
    case deleteMessageError
    
    case sendMessageError
    
    case fetchFriendRequestError
    
    case decodeFriendRequestError
    
    case sendFriendRequestError
    
    case fetchUserError
    
    case deleteUserError
    
    case decodeUserError
    
    case createUserError
    
    case updateUserError
    
    case deleteFriendRequestError
    
    case addFriendRequestError
    
    case createChatRoomError
    
    var errorMessage: String {
        
        switch self {
            
        case .fetchPetError:
            
            return "讀取資料失敗"
            
        case .decodePetError:
            
            return "讀取資料失敗"
            
        case .updatePetError:
            
            return "更新資料失敗"
            
        case .fetchArticleError:
            
            return "讀取資料失敗"
            
        case .updateArticleError:
            
            return "更新資料失敗"
            
        case .publishArticleError:
            
            return "發布資料失敗"
            
        case .decodeArticleError:
            
            return "讀取資料失敗"
            
        case .deleteArticleError:
            
            return "刪除資料失敗"
            
        case .uploadImageError:
            
            return "更新資料失敗"
            
        case .encodeImageError:
            
            return "讀取資料失敗"
            
        case .fetchImageURLError:
            
            return "讀取資料失敗"
            
        case .leaveCommentError:
            
            return "更新資料失敗"
            
        case .toggleLikeArticleError:
            
            return "更新資料失敗"
            
        case .fetchChatRoomError:
            
            return "讀取資料失敗"
            
        case .deleteChatRoomError:
            
            return "刪除資料失敗"
            
        case .fetchMessageError:
            
            return "讀取資料失敗"
            
        case .deleteMessageError:
            
            return "刪除資料失敗"
            
        case .sendMessageError:
            
            return "發布資料失敗"
            
        case .fetchFriendRequestError:
            
            return "讀取資料失敗"
            
        case .decodeFriendRequestError:
            
            return "讀取資料失敗"
            
        case .sendFriendRequestError:
            
            return "發布資料失敗"
            
        case .fetchUserError:
            
            return "讀取資料失敗"
            
        case .deleteUserError:
            
            return "刪除資料失敗"
            
        case .decodeUserError:
            
            return "讀取資料失敗"
            
        case .createUserError:
            
            return "創建資料失敗"
            
        case .updateUserError:
            
            return "更新資料失敗"
            
        case .deleteFriendRequestError:
            
            return "刪除資料失敗"
            
        case .addFriendRequestError:
            
            return "更新資料失敗"
            
        case .createChatRoomError:
            
            return "創建資料失敗"
        }
    }
}
