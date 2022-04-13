//
//  PublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

class PublishViewModel {
    
    let publishContentCategory = PublishContentCategory.allCases
    
    var article: Article = Article(
        id: "", userId: UserManager.shared.currentUser, likeUserIds: [],
        createdTime: 123, postType: 0,
        city: "", petKind: "", color: "",
        content: "", imageURLStrung: "", comments: []
    )
    
    
}
