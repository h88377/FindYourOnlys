//
//  AdoptFavoriteHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/12.
//

import UIKit

class AdoptDetailHeaderView: UIView {
    
    // MARK: - Properties

    private var imageViewHeight = NSLayoutConstraint()
    
    private var imageViewBottom = NSLayoutConstraint()
    
    private var containerViewHeight = NSLayoutConstraint()
    
    private var containerView = UIView()
    
    let imageView: UIImageView = {
       
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFill
        
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createView()
        
        setupViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Methods
    
    private func createView() {
        
        addSubview(containerView)
        
        containerView.addSubview(imageView)
    }
    
    func setupViewConstraints() {
        
        NSLayoutConstraint.activate([
            
            widthAnchor.constraint(equalTo: containerView.widthAnchor),
            
            centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            heightAnchor.constraint(equalTo: containerView.heightAnchor)])
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        
        containerViewHeight.isActive = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewBottom = imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        
        imageViewBottom.isActive = true
        
        imageViewHeight = imageView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        
        imageViewHeight.isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        containerViewHeight.constant = scrollView.contentInset.top
        
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        
        containerView.clipsToBounds = offsetY <= 0
        
        imageViewBottom.constant = offsetY >= 0
        ? 0
        : -offsetY / 2
        
        imageViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
        
    }
    
    func configureView(with viewModel: PetViewModel) {
        
        imageView.loadImage(viewModel.pet.photoURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
    }
}
