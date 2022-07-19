//
//  PublishKindCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class KindSelectionCell: BasePublishCell {
    
    // MARK: - Properties
    
    @IBOutlet private weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var kindStackView: UIStackView!
    
    private var petImages: [UIImage] {
        
        guard
            let catImage = UIImage.asset(.cat)?.withTintColor(.projectPlaceHolderColor, renderingMode: .alwaysOriginal),
            let dogImage = UIImage.asset(.dog)?.withTintColor(.projectPlaceHolderColor, renderingMode: .alwaysOriginal),
            let othersImage = UIImage.asset(.others)?
                .withTintColor(
                    .projectPlaceHolderColor,
                    renderingMode: .alwaysOriginal)
        else { return [] }
        
        return [catImage, dogImage, othersImage]
    }
    
    private var selectedPetImages: [UIImage] {
        
        guard
            let catImage = UIImage.asset(.cat)?.withTintColor(.white, renderingMode: .alwaysOriginal),
            let dogImage = UIImage.asset(.dog)?.withTintColor(.white, renderingMode: .alwaysOriginal),
            let othersImage = UIImage.asset(.others)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        else { return [] }
        
        return [catImage, dogImage, othersImage]
    }
    
    private var buttons: [UIButton] = []
    
    // MARK: - Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        buttons.forEach { $0.layer.cornerRadius = 15}
    }
    
    override func layoutCell(category: String, article: Article? = nil) {
        
        kindLabel.text = category
        
        switch category {
            
        case PublishContentCategory.petKind.rawValue:
            
            let petKinds = PetKind.allCases
            
            for index in 0..<petKinds.count {
                
                if let article = article {
                    
                    let isSelected = article.petKind == petKinds[index].rawValue
                    
                    createButton(with: petKinds[index].rawValue, index: index, isSelected: isSelected)
                } else {
                    
                    createButton(with: petKinds[index].rawValue, index: index)
                }
            }
            
        case PublishContentCategory.postType.rawValue:
            
            let postTypes = PostType.allCases
            
            for index in 0..<postTypes.count {
                
                if let article = article {
                    
                    let isSelected = article.postType == index
                    
                    createButton(with: postTypes[index].rawValue, index: index, isSelected: isSelected)
                    
                } else {
                    
                    createButton(with: postTypes[index].rawValue, index: index)
                }
            }
            
        default:
            
            let sexes = Sex.allCases
            
            for index in 0..<sexes.count {
                
                createButton(with: sexes[index].rawValue, index: index)
            }
            
        }
    }
    
    override func layoutCell(category: String, condition: AdoptFilterCondition? = nil) {
        
        kindLabel.text = category
        
        switch category {
            
        case AdoptFilterCategory.petKind.rawValue:
            
            let petKinds = PetKind.allCases
            
            for index in 0..<petKinds.count {
                
                if let condition = condition {
                    
                    let isSelected = condition.petKind == petKinds[index].rawValue
                    
                    createButton(with: petKinds[index].rawValue, index: index, isSelected: isSelected)
                } else {
                    
                    createButton(with: petKinds[index].rawValue, index: index)
                }
            }
            
        default:
            
            let sexTypes = Sex.allCases
            
            for index in 0..<sexTypes.count {
                
                if let condition = condition {
                    
                    let isSelected = condition.sex == convertSex(with: sexTypes[index])
                    
                    createButton(with: sexTypes[index].rawValue, index: index, isSelected: isSelected)
                    
                } else {
                    
                    createButton(with: sexTypes[index].rawValue, index: index)
                }
            }
            
        }
    }
    
    override func layoutCell(category: String, findCondition: FindPetSocietyFilterCondition? = nil) {
        
        kindLabel.text = category
        
        switch category {
            
        case FindPetSocietyFilterCategory.petKind.rawValue:
            
            let petKinds = PetKind.allCases
            
            for index in 0..<petKinds.count {
                
                if let findCondition = findCondition {
                    
                    let isSelected = findCondition.petKind == petKinds[index].rawValue
                    
                    createButton(with: petKinds[index].rawValue, index: index, isSelected: isSelected)
                    
                } else {
                    
                    createButton(with: petKinds[index].rawValue, index: index)
                }
            }
            
        case FindPetSocietyFilterCategory.postType.rawValue:
            
            let postTypes = PostType.allCases
            
            for index in 0..<postTypes.count {
                
                if let findCondition = findCondition {
                    
                    let isSelected = findCondition.postType == index
                    
                    createButton(with: postTypes[index].rawValue, index: index, isSelected: isSelected)
                    
                } else {
                    
                    createButton(with: postTypes[index].rawValue, index: index)
                }
            }
            
        default:
            
            let sexes = Sex.allCases
            
            for index in 0..<sexes.count {
                
                createButton(with: sexes[index].rawValue, index: index)
            }
            
        }
    }
    
    private func createButton(with title: String, index: Int, isSelected: Bool = false) {
        
        let button = TransformButton()
        
        if kindLabel.text == PublishContentCategory.petKind.rawValue {
            
            button.setImage(petImages[index], for: .normal)
            
            button.setImage(selectedPetImages[index], for: .selected)
            
            button.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            button.setTitle(title, for: .normal)
            
            button.titleLabel?.alpha = 0
            
        } else {
            
            button.setTitle(title, for: .normal)
        }
        
        button.setTitleColor(.projectPlaceHolderColor, for: .normal)
        
        button.setTitleColor(.white, for: .selected)
        
        button.isSelected = isSelected
        
        button.backgroundColor = isSelected
        ? .projectIconColor1
        : .projectBackgroundColor
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(toggleButton), for: .touchUpInside)
        
        buttons.append(button)
        
        kindStackView.addSubview(button)
        
        NSLayoutConstraint.activate([
            
            button.heightAnchor.constraint(equalTo: kindStackView.heightAnchor),
            
            button.widthAnchor.constraint(equalToConstant: 60),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            
            button.topAnchor.constraint(equalTo: kindStackView.topAnchor),
            
            button.leadingAnchor.constraint(equalTo: kindStackView.leadingAnchor,constant: (80 * CGFloat(index)))])
    }
    
    private func convertSex(with sexType: Sex) -> String {
        
        switch sexType {
            
        case .male:
            
            return "M"
            
        case .female:
            
            return "F"
        }
    }
    
    @objc func toggleButton(_ sender: UIButton) {
        
        guard let currentTitle = sender.currentTitle else { return }
        
        buttons.forEach {
            
            $0.isSelected = false
            
            $0.backgroundColor = .projectBackgroundColor
        }
        
        sender.isSelected = true
        
        sender.backgroundColor = .projectIconColor1
        
        switch kindLabel.text {
            
        case PublishContentCategory.petKind.rawValue:
            
            delegate?.didChangePetKind(self, with: currentTitle)
            
        case PublishContentCategory.postType.rawValue:
            
            delegate?.didChangePostType(self, with: currentTitle)
            
        default:
            
            delegate?.didChangeSex(self, with: currentTitle)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        buttons.forEach { $0.removeFromSuperview() }
    }
}
