//
//  PublishMediaCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishContentCell: PublishBasicCell {
    
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
            
            cameraButton.tintColor = .systemGray2
        }
    }
    @IBOutlet weak var galleryButton: UIButton! {
        
        didSet {
            
            galleryButton.tintColor = .systemGray2
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentTextView.layer.cornerRadius = 5
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        
        cameraHandler?()
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
        
        galleryHandler?()
    }
    
    override func layoutCellWith(image: UIImage) {
        
        contentImageView.image = image
    }
    
    override func layoutCell(article: Article? = nil) {
        
        if
            let article = article {
            
            contentTextView.text = article.content
            
            contentTextView.textColor = .black
            
            contentImageView.loadImage(article.imageURLString)
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
