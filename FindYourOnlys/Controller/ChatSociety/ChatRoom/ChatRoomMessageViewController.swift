//
//  ChatRoomThreadViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit

class ChatRoomMessageViewController: BaseViewController {
    
    private enum MessageType: String {
        
        case placeHolder = "請輸入訊息"
        
        case block = "該用戶已經被您封鎖"
    }
    
    // MARK: - Properties
    
    let viewModel = ChatRoomMessageViewModel()
    
    @IBOutlet private weak var messageTextView: UITextView! {
        
        didSet {
            
            messageTextView.delegate = self
            
            messageTextView.text = MessageType.placeHolder.rawValue
            
            messageTextView.textColor = UIColor.systemGray3
            
            messageTextView.layer.borderWidth = 1
            
            messageTextView.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    @IBOutlet private weak var sendMessageButton: UIButton! {
        
        didSet {
            
            sendMessageButton.tintColor = sendMessageButton.isEnabled
            ? .projectIconColor1
            : .projectPlaceHolderColor
        }
    }
    
    @IBOutlet private weak var galleryButton: UIButton!
    
    @IBOutlet private weak var cameraButton: UIButton!
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenIQKeyboardToolBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.messageViewModels.bind { [weak self] _ in
            
            guard let self = self else { return }
            
            self.tableView.reloadData()
            
            self.scrollToBottomIfHasMessage()
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self,
                let error = errorViewModel?.error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel.checkIsBlockHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.checkIsBlock()
        }
        
        addCurrentUserObserver()
        
        viewModel.fetchMessage()
        
        viewModel.checkIsBlocked()
        
        checkMessageButton()
    }
    
    // MARK: - Methods and IBActions
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        messageTextView.centerVertically()
        
        messageTextView.layer.cornerRadius = 5
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = viewModel.selectedFriend?.nickName
        
        let editImage = UIImage.asset(.edit)?.withTintColor(.projectIconColor1, renderingMode: .alwaysOriginal)
        
        let itemImage = UIImage.resizeImage(image: editImage!, targetSize: CGSize(width: 20, height: 20))
        
        let editItem = UIBarButtonItem(
            image: itemImage,
            style: .plain,
            target: self,
            action: #selector(block))
        
        navigationItem.rightBarButtonItem = editItem
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomUserMessageCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomFriendMessageCell.identifier)
        
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
    
    @objc func block(sender: UIBarButtonItem) {
        
        let blockConfirmAction = UIAlertAction(title: "封鎖", style: .destructive) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.viewModel.blockUser()
        }
        
        AlertWindowManager.shared.presentBlockActionSheet(at: self, with: blockConfirmAction)
    }
    
    private func scrollToBottomIfHasMessage() {
        
        let messageCount = viewModel.messageViewModels.value.count
        
        guard messageCount > 0 else { return }
        
        let indexPath = IndexPath(row: messageCount - 1, section: 0)
        
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    private func checkIsBlock() {
        
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.isBlocked
        
        cameraButton.isEnabled = !viewModel.isBlocked
        
        galleryButton.isEnabled = !viewModel.isBlocked
        
        sendMessageButton.isEnabled = !viewModel.isBlocked
        
        messageTextView.isEditable = !viewModel.isBlocked
        
        if viewModel.isBlocked {
            
            messageTextView.text = MessageType.block.rawValue
        }
    }
    
    private func checkMessageButton() {
        
        if messageTextView.text != MessageType.placeHolder.rawValue &&
            messageTextView.text != MessageType.block.rawValue &&
            messageTextView.text?.isEmpty == false {
            
            sendMessageButton.isEnabled = true
            
        } else {
            
            sendMessageButton.isEnabled = false
        }
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil)
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchMessage()
        
        viewModel.checkIsBlocked()
    }
       
    @IBAction func sendMessage(_ sender: UIButton) {
        
        viewModel.changedContent(with: messageTextView.text)
        
        viewModel.sendMessage()
        
        messageTextView.text = ""

        messageTextView.textColor = UIColor.systemGray3

        checkMessageButton()
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        
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
    
    @IBAction func openGallery(_ sender: UIButton) {
        
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

// MARK: - UITableViewDelegate and DataSource

extension ChatRoomMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.messageViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let userCell = tableView.dequeueReusableCell(
                withIdentifier: ChatRoomUserMessageCell.identifier, for: indexPath
            ) as? ChatRoomUserMessageCell,
            let friendCell = tableView.dequeueReusableCell(
                withIdentifier: ChatRoomFriendMessageCell.identifier, for: indexPath
            ) as? ChatRoomFriendMessageCell,
            let selectedFriend = viewModel.selectedFriend
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.messageViewModels.value[indexPath.row]
        
        if cellViewModel.message.senderId == selectedFriend.id {
            
            friendCell.configureCell(with: cellViewModel, friend: selectedFriend)
            
            return friendCell
            
        } else {
            
            userCell.configureCell(with: cellViewModel, friend: selectedFriend)
            
            return userCell
        }
    }
}

// MARK: - UITextViewDelegate
extension ChatRoomMessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if messageTextView.textColor == UIColor.systemGray3 {
            
            messageTextView.text = nil
            
            messageTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        checkMessageButton()
        
        if messageTextView.textColor == UIColor.systemGray3 {
            
            messageTextView.textColor = UIColor.black
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChatRoomMessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        dismiss(animated: true)
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            viewModel.changeContent(with: editedImage)
            
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        
            viewModel.changeContent(with: image)
        }
    }
}
