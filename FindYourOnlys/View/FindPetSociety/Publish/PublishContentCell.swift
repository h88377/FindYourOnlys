//
//  PublishMediaCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishContentCell: BasePublishCell {
    
    @IBOutlet weak var photoLabel: UILabel! {
        
        didSet {
            
            photoLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel! {
        
        didSet {
            
            contentLabel.textColor = .projectTextColor
        }
    }
    @IBOutlet weak var imageBaseView: UIView! {
        
        didSet {
            
//            imageBaseView.layer.borderColor = UIColor.projectIconColor2.cgColor
//
//            imageBaseView.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var contentTextView: UITextView! {
        
        didSet {
            
            contentTextView.delegate = self
            
            contentTextView.text = "請輸入你的內文"
            
            contentTextView.textColor = UIColor.systemGray3
            
            contentTextView.layer.borderWidth = 1
            
            contentTextView.layer.borderColor = UIColor.systemGray5.cgColor
            
        }
    }
    
    @IBOutlet weak var cameraButton: UIButton! {
        
        didSet {
            
            cameraButton.tintColor = .projectIconColor1
        }
    }
    @IBOutlet weak var galleryButton: UIButton! {
        
        didSet {
            
            galleryButton.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var detectButton: UIButton! {
        
        didSet {
            
            detectButton.setTitleColor(.white, for: .normal)
            
            detectButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            detectButton.titleLabel?.font = UIFont.systemFont(ofSize: Constant.textSize, weight: .medium)
            
            detectButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var separatorView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentTextView.layer.cornerRadius = 5
        
        contentImageView.layer.cornerRadius = 15
        
        detectButton.layer.cornerRadius = 10
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        
        cameraHandler?()
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
        
        galleryHandler?()
    }
    
    @IBAction func imageDetect(_ sender: UIButton) {
        
        imageDetectHandler?()
    }
    
    override func layoutCellWith(image: UIImage) {
        
        contentImageView.image = image
    }
    
    override func layoutCell(article: Article? = nil) {
        
        if
            let article = article {
            
            contentTextView.text = article.content
            
            contentTextView.textColor = .black
            
            contentImageView.loadImage(article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        }
    }
    
    func customDoneToolBar() -> UIToolbar {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        
        toolbar.setItems([flexibleSpace, doneBtn], animated: true)
        
        return toolbar
    }
    
    @objc func donePressed() {

        contentTextView.endEditing(true)
    }
}

// MARK: - UITextViewDelegate
extension PublishContentCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.systemGray3 {
            
            textView.text = nil
            
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            textView.text = "請輸入你的內文"
            
            textView.textColor = UIColor.systemGray3
        }
        
        delegate?.didChangeContent(self, with: textView.text)
    }
}
