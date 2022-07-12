//
//  PetSocietyCommentViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import Foundation

class PetSocietyCommentViewModel {
    
    // MARK: - Properties
    var selectedArticle: Article?
    
    var selectedAuthor: User?
    
    var selectedArticleViewModel: Box<ArticleViewModel?> = Box(nil)
    
    var commentViewModels = Box([CommentViewModel]())
    
    var senderViewModels = Box([UserViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    private var comment = Comment()
    
    var beginEditCommentHander: (() -> Void)?
    
//    var scrollToBottomHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var signInHandler: (() -> Void)?
    
//    var blockHandler: ((UserViewModel) -> Void)?
    
    // MARK: - Methods
    
    func fetchComments() {

        guard
            let selectedArticle = selectedArticle else { return }

        PetSocietyFirebaseManager.shared.fetchArticle(withArticleId: selectedArticle.id) { [weak self] result in

            guard
                let self = self else { return }

            switch result {

            case .success(var article):
                
                if
                    let currentUser = UserFirebaseManager.shared.currentUser {
                    
                    let filteredComments = article.comments.filter { !currentUser.blockedUsers.contains($0.userId) }
                    
                    article.comments = filteredComments
                }
                    
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

        PetSocietyFirebaseManager.shared.leaveComment(withArticle: &article, comment: comment) { [weak self] result in
            
            guard
                let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func beginEditMessage() {
        
        guard
            UserFirebaseManager.shared.currentUser != nil
                
        else {
            
            signInHandler?()
            
            return
        }
        
        beginEditCommentHander?()
    }
    
//    func scrollToBottom() {
//
//        scrollToBottomHandler?()
//    }
    
//    func block(with senderViewModel: UserViewModel) {
//
//        blockHandler?(senderViewModel)
//    }
    
    func blockUser(with viewModel: UserViewModel) {
        
        let user = viewModel.user
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.blockUser(with: user.id)
        
        stopLoadingHandler?()
    }
    
    func changedContent(with contentText: String) {
        
        comment.content = contentText
    }
    
    private func fetchSenders(withArticle article: Article) {

        let userIds = article.comments.map { $0.userId }
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let users):
                
                let senders = self.getCommentedUsers(users: users, with: userIds)
                
                UserFirebaseManager.shared.setUsers(with: self.senderViewModels, users: senders)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
            }
        }
    }
    
    private func getCommentedUsers(users: [User], with userIds: [String]) -> [User] {
        
        var senders = [User]()
        
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
        
        return senders
    }
}
