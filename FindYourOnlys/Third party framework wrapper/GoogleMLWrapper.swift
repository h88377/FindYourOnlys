//
//  GoogleMLWrapper.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/12.
//

import Foundation
import MLKit

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

enum GoogleMLError: Error {
    
    case detectError
    
    case detectFailure
    
    case noImage
    
    var errorMessage: String {
        
        switch self {
            
        case .detectError:
            
            return "圖片辨識失敗，請重新嘗試或換照片後再嘗試一次。"
            
        case .detectFailure:
            
            return "照片中無動物，請重新嘗試或換照片後再嘗試一次。"
            
        case .noImage:
            
            return "請先選擇照片再進行辨識喔！"
        }
    }
}

class GoogleMLWrapper {
    
    // MARK: - Property
    static let shared = GoogleMLWrapper()
    
    private init() { }
    
    // MARK: - Methods
    
    func detectLabels(
        with image: UIImage,
        completion: @escaping (Result<[ImageLabel], Error>) -> Void) {
        
        let visionImage = VisionImage(image: image)
        
        visionImage.orientation = image.imageOrientation
        
        let options = ImageLabelerOptions()
        
        options.confidenceThreshold = 0.7
        
        let labeler = ImageLabeler.imageLabeler(options: options)
        
        labeler.process(visionImage) { labels, error in
            
            guard
                error == nil,
                let labels = labels
            
            else {
                
                completion(.failure(GoogleMLError.detectError))
                    
                    return
                }
            
            completion(.success(labels))
        }
    }
    
    func getDetectResult(with labels: [ImageLabel]) -> Bool {
        
        let imageDetectDatabase = ImageDetectDatabase.allCases.map { $0.rawValue }
        
        let isValidResult = labels.map { label in
            
            imageDetectDatabase.contains(label.text)
            
        }.contains(true)
        
        return isValidResult
    }
}
