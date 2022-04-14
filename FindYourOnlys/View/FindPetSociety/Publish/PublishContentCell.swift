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
            
            contentTextView.text = "Here is your story"
            
            contentTextView.textColor = UIColor.systemGray3
            
            contentTextView.layer.borderWidth = 1
            
            contentTextView.layer.borderColor = UIColor.systemGray5.cgColor
            
            contentTextView.inputAccessoryView = customDoneToolBar()
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
            
            textView.text = "Here is your story"
            
            textView.textColor = UIColor.systemGray3
        }
        
        delegate?.didChangeContent(self, with: textView.text)
    }
}
