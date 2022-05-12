//
//  PublishViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import UIKit.UIImage

enum ImageDetectDatabase: String, CaseIterable {
    
    case bird = "Bird"
    
    case pomacentridae = "Pomacentridae"
    
    case shetlandSheepdog = "Shetland sheepdog"
    
    case bear = "Bear"
    
    case cattle = "Cattle"
    
    case cat = "Cat"
    
    case dinosaur = "Dinosaur"
    
    case dragon = "Dragon"
    
    case jersey = "Jersey"
    
    case waterfowl = "Waterfowl"
    
    case cairnTerrier = "Cairn terrier"
    
    case horse = "Horse"
    
    case herd = "Herd"
    
    case insect = "Insect"
    
    case penguin = "Penguin"
    
    case pet = "Pet"
    
    case duck = "Duck"
    
    case turtle = "Turtle"
    
    case crocodile = "Crocodile"
    
    case dog = "Dog"
    
    case bull = "Bull"
    
    case butterfly = "Butterfly"
    
    case larva = "Larva"
    
    case sphynx = "Sphynx"
    
    case bassetHound = "Basset hound"
}

class PublishViewModel {
    
    let publishContentCategory = PublishContentCategory.allCases
    
    var article: Article = Article(
        id: "", userId: UserFirebaseManager.shared.currentUser?.id ?? "", likeUserIds: [],
        createdTime: 0, postType: -1,
        city: "", petKind: "", color: "",
        content: "", imageURLString: "", comments: []
    )
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var updateImage: ((UIImage) -> Void)?
    
    var selectedImage: UIImage?
    
    var checkPublishedContent: ((Bool, Bool) -> Void)?
    
    var isValidPublishedContent: Bool {
        
        guard
            article.city != "",
            article.color != "",
            article.petKind != "",
            article.postType != -1,
            article.content != "",
            selectedImage != nil
                
        else { return false }
            
        return true
    }
    
    var isValidDetectResult: Bool = false
    
    var dismissHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var imageDetectHandler: (() -> Void)?
    
    private func publish(completion: @escaping (Result<String, Error>) -> Void) {
        
        checkPublishedContent?(isValidPublishedContent, isValidDetectResult)
        
        guard
            isValidPublishedContent,
            isValidDetectResult,
            let selectedImage = selectedImage
                
        else { return }
        
        DispatchQueue.global().async { [weak self] in
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser,
                let self = self
                    
            else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.startLoadingHandler?()
            
            PetSocietyFirebaseManager.shared.fetchDownloadImageURL(
                image: selectedImage,
                with: FirebaseCollectionType.article.rawValue)
            { result in
                
                switch result {
                    
                case .success(let url):
                    
                    self.article.imageURLString = "\(url)"
                    
//                    completion(nil)
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    
//                    self.stopLoadingHandler?()
                }

                semaphore.signal()
            }
            

            semaphore.wait()
            PetSocietyFirebaseManager.shared.publishArticle(currentUser.id, with: &self.article) { result in

                switch result {
                    
                case .success(let success):
                    
//                    completion(nil)
                    
//                    self.stopLoadingHandler?()
                    
                    completion(.success(success))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
                    
//                    self.errorViewModel.value = ErrorViewModel(model: error)
//
//                    self.stopLoadingHandler?()
                }
                
                semaphore.signal()
            }
            
        }
    }
    
    func tapPublish() {
        
        publish { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                self?.stopLoadingHandler?()
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}

extension PublishViewModel {
    
    func cityChanged(with city: String) {
        
        self.article.city = city
    }
    
    func colorChanged(with color: String) {
        
        self.article.color = color
    }
    
    func petKindChanged(with petKind: String) {
        
        self.article.petKind = petKind
    }
    
    func postTypeChanged(with type: String) {
        
        if type == PostType.missing.rawValue {
            
            self.article.postType = 0
            
        } else {
            
            self.article.postType = 1
        }
    }
    
    func contentChanged(with content: String) {
        
        self.article.content = content
    }
}
