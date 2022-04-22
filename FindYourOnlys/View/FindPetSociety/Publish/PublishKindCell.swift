//
//  PublishKindCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishKindCell: PublishBasicCell {

    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var kindStackView: UIStackView!
    
    var buttons: [UIButton] = []
    
    override func layoutCell(category: String) {
        
        kindLabel.text = category
    
        
        switch category {
            
        case PublishContentCategory.petKind.rawValue:
            
            let petKinds = PetKind.allCases

            for index in 0..<petKinds.count {

                createButton(with: petKinds[index].rawValue, index: index)
            }
        case PublishContentCategory.postType.rawValue:
            
            let postTypes = PostType.allCases

            for index in 0..<postTypes.count {

                createButton(with: postTypes[index].rawValue, index: index)
            }
            
        default:
            
            let sexes = Sex.allCases

            for index in 0..<sexes.count {

                createButton(with: sexes[index].rawValue, index: index)
            }
            
        }
        
    
        
        
        
//        if category == PublishContentCategory.petKind.rawValue {
//
//            let petKinds = PetKind.allCases
//
//            for index in 0..<petKinds.count {
//
//                createButton(with: petKinds[index].rawValue, index: index)
//            }
//
//        } else {
//
//            let postTypes = PostType.allCases
//
//            for index in 0..<postTypes.count {
//
//                createButton(with: postTypes[index].rawValue, index: index)
//            }
//        }

    }
    
    func createButton(with title: String, index: Int) {
        
        let screenWidth = UIScreen.main.bounds.width
        
        let button = UIButton()

        button.setTitle(title, for: .normal)
        
        button.setTitleColor(.systemGray2, for: .normal)
        
        button.setTitleColor(.black, for: .selected)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
        
        buttons.append(button)

        kindStackView.addSubview(button)

        NSLayoutConstraint.activate(
            [
                button.widthAnchor.constraint(equalToConstant: (screenWidth - 32) / 3),
                
                button.heightAnchor.constraint(equalTo: kindStackView.heightAnchor),
                
                button.topAnchor.constraint(equalTo: kindStackView.topAnchor),
                
                button.leadingAnchor.constraint(equalTo: kindStackView.leadingAnchor, constant: ((screenWidth - 32) / 3) * CGFloat(index) )
            ]
        )
    }
    
    @objc func toggleButton(_ sender: UIButton) {
        
        guard
            let currentTitle = sender.currentTitle
        
        else { return }
        
        buttons.forEach { $0.isSelected = false }
        
        sender.isSelected = true
        
        if kindLabel.text == PublishContentCategory.petKind.rawValue {
            
            delegate?.didChangePetKind(self, with: currentTitle)
            
        } else {
            
            delegate?.didChangePostType(self, with: currentTitle)
        }
    }
    
}
