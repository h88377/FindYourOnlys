//
//  PublishKindCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishKindCell: PublishBasicCell {
    
    private enum PetKind: String, CaseIterable {
        
        case cat = "貓咪"
        
        case dog = "狗狗"
        
        case others = "其他"
    }

    private enum PetDescription: String, CaseIterable {
        
        case missing = "遺失"
        
        case found = "尋獲"
    }

    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var kindStackView: UIStackView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
    }
    
    
    override func layoutCell(category: String) {
        
        kindLabel.text = category
    
        if kindLabel.text == PublishContentCategory.petKind.rawValue {

            let petKinds = PetKind.allCases

            for index in 0..<petKinds.count {

                let button = UIButton()
                
                let screenWidth = UIScreen.main.bounds.width

                button.setTitle(petKinds[index].rawValue, for: .normal)

                button.setTitleColor(.systemBlue, for: .normal)

                kindStackView.addSubview(button)

                button.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate(
                    [
                        button.widthAnchor.constraint(equalToConstant: (screenWidth - 32) / 3),
                        button.heightAnchor.constraint(equalTo: kindStackView.heightAnchor),
                        button.topAnchor.constraint(equalTo: kindStackView.topAnchor),
                        button.leadingAnchor.constraint(equalTo: kindStackView.leadingAnchor, constant: ((screenWidth - 32) / 3) * CGFloat(index) )
                    ]
                )
            }

        } else {

            let petDescriptions = PetDescription.allCases

            for index in 0..<petDescriptions.count {

                let button = UIButton()
                
                let screenWidth = UIScreen.main.bounds.width

                button.setTitle(petDescriptions[index].rawValue, for: .normal)
                
                button.setTitleColor(.systemBlue, for: .normal)

                kindStackView.addSubview(button)

                button.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate(
                    [
                        button.widthAnchor.constraint(equalToConstant: (screenWidth - 32) / 3),
                        button.heightAnchor.constraint(equalTo: kindStackView.heightAnchor),
                        button.topAnchor.constraint(equalTo: kindStackView.topAnchor),
                        button.leadingAnchor.constraint(equalTo: kindStackView.leadingAnchor, constant: ((screenWidth - 32) / 3) * CGFloat(index) )
                    ]
                )
            }
        }

    }
    
}
