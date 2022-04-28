//
//  PetSocietyCommentViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import Foundation

class PetSocietyCommentViewModel {
    
    var selectedArticle: Article?
    
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
    
    var editCommentHandler: (() -> Void)?
    
    var beginEditCommentHander: (() -> Void)?
    
    var endEditCommentHandler: (() -> Void)?
    
    var scrollToBottomHandler: (() -> Void)?
    
    func editMessage() {
        
        editCommentHandler?()
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
                
                for userId in userIds {
                    
                    for user in users where userId == user.id {
                            
                        senders.append(user)
                    }
                }
                
                UserFirebaseManager.shared.setUsers(with: self.senderViewModels, users: senders)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
            }
        }
    }
}

extension PetSocietyCommentViewModel {
    
    func changedContent(with contentText: String) {
        
        comment.content = contentText
    }
}
