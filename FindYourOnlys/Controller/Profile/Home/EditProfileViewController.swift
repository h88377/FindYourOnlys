//
//  EditProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import UIKit

class EditProfileViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = EditProfileViewModel()
    
    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet weak var nickNameTitleLabel: UILabel! {
        
        didSet {
            
            nickNameTitleLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var nickNameTextField: ContentInsetTextField! {
        
        didSet {
            
            nickNameTextField.placeholder = "請輸入你的暱稱"
            
            nickNameTextField.delegate = self
        }
    }
    
    @IBOutlet private weak var confirmButton: UIButton! {
        
        didSet {
            
            confirmButton.setTitleColor(.white, for: .normal)
            
            confirmButton.backgroundColor = .projectIconColor1
            
            confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
            
            remindLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    override var isHiddenTabBar: Bool { return true }

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.error.bind { [weak self] error in
            
            guard
                let self = self,
                let error = error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel.checkEditedUserHandler = { [weak self] isValid in
            
            guard let self = self else { return }
            
            if !isValid {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "內容不足", message: "請完整填寫內容再更新資訊喔！")
            }
        }
        
        setupBackHandler()
        
        setupProfile()
    }
    
    // MARK: - Methods and IBActions
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "編輯資訊"
        
        let barButtonItem = UIBarButtonItem(title: "刪除帳號", style: .done, target: self, action: #selector(deleteAccount))
        
        barButtonItem.tintColor = .red
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        confirmButton.layer.cornerRadius = 15
        
        userImageView.layer.cornerRadius = 15
    }
    
    override func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in

            guard let self = self else { return }
            
            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.stopLoading()
        }
    }
    
    private func setupBackHandler() {
        
        viewModel.dismissHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.popBack()
        }
        
        viewModel.backToHomeHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.tabBarController?.selectedIndex = 0
        }
    }

    @objc private func deleteAccount(sender: UIBarButtonItem) {
        
        showDeleteWindow(title: "警告", message: "您將刪除個人帳號，確定要刪除帳號嗎？")
    }
    
    private func setupProfile() {
        
        guard let currentUser = viewModel.currentUser else { return }
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeImage))
        
        tapGesture.numberOfTapsRequired = 1
        
        userImageView.loadImage(
            currentUser.imageURLString,
            placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        userImageView.contentMode = .scaleAspectFill
        
        userImageView.addGestureRecognizer(tapGesture)
        
        userImageView.isUserInteractionEnabled = true
        
        nickNameTextField.text = currentUser.nickName
        
    }
    
    @objc func changeImage(_ sender: UITapGestureRecognizer) {
            
        let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let openGallery = UIAlertAction(title: "開啟相簿", style: .default) { _ in
            
            self.openGallery()
        }
        
        let openCamera = UIAlertAction(title: "開啟相機", style: .default) { _ in
            
            self.openCamera()
        }
        
        alert.addAction(cancel)
        
        alert.addAction(openGallery)
        
        alert.addAction(openCamera)
        
        // iPad specific code
        alert.popoverPresentationController?.sourceView = self.view
        
        let xOrigin = self.view.bounds.width / 2
        
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        
        alert.popoverPresentationController?.sourceRect = popoverRect
        
        alert.popoverPresentationController?.permittedArrowDirections = .up
        
        present(alert, animated: true)
        
    }
    
    func showDeleteWindow(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            
            self?.viewModel.deleteUser()
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(cancel)
        
        alert.addAction(delete)
        
        present(alert, animated: true)
    }
    
    @IBAction func confirm(_ sender: UIButton) {
        
        viewModel.tapConfirm()
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        
        dismiss(animated: true)
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            userImageView.image = editedImage
            
            viewModel.selectedImage = editedImage
            
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            userImageView.image = image
            
            viewModel.selectedImage = image
        }
    }
    
    func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true)
            
        } else {

            AlertWindowManager.shared.showAlertWindow(at: self, title: "異常", message: "你的裝置沒有相機喔！")
        }
    }
    
    func openGallery() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true)
            
        } else {
            
            AlertWindowManager.shared.showAlertWindow(at: self, title: "異常", message: "你沒有打開開啟相簿權限喔！")
        }
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let nickName = nickNameTextField.text else { return }
        
        viewModel.nickNameChange(with: nickName)
    }
}
