//
//  PetSocietyCommentViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import Foundation

class PetSocietyCommentViewModel {
    
    var selectedArticle: Article?
    
    var selectedAuthor: User?
    
    var selectedArticleViewModel: Box<ArticleViewModel?> = Box(nil)
    
    var commentViewModels = Box([CommentViewModel]())
    
    var senderViewModels = Box([UserViewModel]())
    
    var comment = Comment(
        articleId: "",
        userId: "",
        content: "",
        createdTime: -1
    )
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var changeCommentHandler: (() -> Void)?
    
    var beginEditCommentHander: (() -> Void)?
    
    var endEditCommentHandler: (() -> Void)?
    
    var scrollToBottomHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var blockHandler: ((UserViewModel) -> Void)?
    
    func changeMessage() {
        
        changeCommentHandler?()
    }
    
    func beginEditMessage() {
        
        beginEditCommentHander?()
    }
    
    func endEditMessage() {
        
        endEditCommentHandler?()
    }
    
    func scrollToBottom() {
        
        scrollToBottomHandler?()
    }
    
    func block(with senderViewModel: UserViewModel) {
        
        blockHandler?(senderViewModel)
    }
    
    func fetchComments() {

        guard
            let selectedArticle = selectedArticle else { return }

        PetSocietyFirebaseManager.shared.fetchArticle(withArticleId: selectedArticle.id) { [weak self] result in

            guard
                let self = self else { return }

            switch result {

            case .success(let article):
                
                self.selectedArticleViewModel.value = ArticleViewModel(model: article)

                PetSocietyFirebaseManager.shared.setComments(with: self.commentViewModels, comments: article.comments)
                
                self.fetchSenders(withArticle: article)

            case .failure(let error):

                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func leaveComment() {
        
        guard
            var article = selectedArticleViewModel.value?.article,
            let currentUser = UserFirebaseManager.shared.currentUser
                
        else { return }
        
        comment.articleId = article.id

        comment.userId = currentUser.id

        comment.createdTime = NSDate().timeIntervalSince1970

        PetSocietyFirebaseManager.shared.leaveComment(withArticle: &article, comment: comment) { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
        }
    }
    
    private func fetchSenders(withArticle article: Article) {

        let userIds = article.comments.map { $0.userId }
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                var senders = [User]()
                
//                for userId in userIds {
//
//                    for user in users where userId == user.id {
//
//                        senders.append(user)
//                    }
//                }
                
                for userId in userIds {
                        
                    if !users.map({ $0.id }).contains(userId) {
                        
                        let deletedUser = User(
                            id: "", nickName: "不存在使用者",
                            email: "",
                            imageURLString: "",
                            friends: [],
                            blockedUsers: []
                        )

                        senders.append(deletedUser)
                        
                    } else {
                        
                        for user in users where user.id == userId {
                            
                            senders.append(user)
                            
                            break
                        }
                    }
                           
                }
                
                UserFirebaseManager.shared.setUsers(with: self.senderViewModels, users: senders)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
            }
        }
    }
    
    func blockUser(with viewModel: UserViewModel) {
        
        let user = viewModel.user
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.blockUser(with: user.id) { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
        }
        
        stopLoadingHandler?()
    }
}

extension PetSocietyCommentViewModel {
    
    func changedContent(with contentText: String) {
        
        comment.content = contentText
    }
}
