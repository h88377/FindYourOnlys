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

    }
    
    @IBOutlet weak var messageTextView: UITextView! {
        
        didSet {
            
            messageTextView.delegate = self
            
            messageTextView.text = MessageType.placeHolder.rawValue
            
            messageTextView.textColor = UIColor.systemGray3
            
            messageTextView.layer.borderWidth = 1
            
            messageTextView.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var sendMessageButton: UIButton! {
        
        didSet {
            
            sendMessageButton.tintColor = sendMessageButton.isEnabled
            ? .projectIconColor1
            : .projectPlaceHolderColor
        }
    }
    
    @IBOutlet weak var galleryButton: UIButton!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    let viewModel = ChatRoomMessageViewModel()
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenIQKeyboardToolBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.checkIsBlockHandler = { [weak self] in
            
            self?.checkIsBlock()
        }
        
        viewModel.checkIsBlocked()
        
        viewModel.fetchMessage()
        
        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error == nil
                    
            else {
                
                print(errorViewModel?.error.localizedDescription)
                
                return
            }
        }
        
        viewModel.messageViewModels.bind { [weak self] _ in
            
            self?.tableView.reloadData()
            
            self?.viewModel.scrollToBottom()
        }
        
        viewModel.beginEditMessageHander = { [weak self ] in
            
            if self?.messageTextView.textColor == UIColor.systemGray3 {
                
                self?.messageTextView.text = nil
                
                self?.messageTextView.textColor = UIColor.black
            }
        }
        
        viewModel.changeMessageHandler = { [weak self] in
            
            self?.checkMessageButton()
            
            if self?.messageTextView.textColor == UIColor.systemGray3 {
                
                self?.messageTextView.textColor = UIColor.black
            }
        }
        
        viewModel.scrollToBottomHandler = { [weak self] in
            
            guard
                let messageCount = self?.viewModel.messageViewModels.value.count,
                messageCount > 0
                    
            else { return }
            
            let indexPath = IndexPath(row: messageCount - 1, section: 0)
            
            self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
        viewModel.endEditMessageHandler = { [weak self] in
            
            self?.messageTextView.text = MessageType.placeHolder.rawValue

            self?.messageTextView.textColor = UIColor.systemGray3
            
            self?.checkMessageButton()
        }
        
        viewModel.enableIQKeyboardHandler = { [weak self] in
            
            //Wait handle content out of screen when user tap textView.
        }
        
        viewModel.startLoadingHandler = { [weak self] in

            guard
                let self = self else { return }
            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.startLoading(at: self.view)
            }
        }
        
        viewModel.stopLoadingHandler = {

            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.stopLoading()
            }
        }
        
        checkMessageButton()
    }
    
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
            action: #selector(block)
        )
        
        navigationItem.rightBarButtonItem = editItem
    }
    
    @objc func block(sender: UIBarButtonItem) {
        
        presentBlockActionSheet()
    }
    
    func checkIsBlock() {
        
        navigationItem.rightBarButtonItem?.isEnabled = !viewModel.isBlocked
        
        cameraButton.isEnabled = !viewModel.isBlocked
        
        galleryButton.isEnabled = !viewModel.isBlocked
        
        sendMessageButton.isEnabled = !viewModel.isBlocked
        
        messageTextView.isEditable = !viewModel.isBlocked
        
        if viewModel.isBlocked {
            
            messageTextView.text = "該用戶已經被您封鎖"
        }
    }
    
    func checkMessageButton() {
        
        if messageTextView.text != MessageType.placeHolder.rawValue
            && messageTextView.text?.isEmpty == false {
            
            sendMessageButton.isEnabled = true
            
        } else {
            
            sendMessageButton.isEnabled = false
        }
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomUserMessageCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomFriendMessageCell.identifier)
        
    }
       
    @IBAction func sendMessage(_ sender: UIButton) {
        
        viewModel.changedContent(with: messageTextView.text)
        
        viewModel.sendMessage { error in
            
            print(error)
        }
        
        messageTextView.text = ""

        messageTextView.textColor = UIColor.systemGray3

        checkMessageButton()
    }
    
    private func presentBlockActionSheet() {
        
        let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let blockAction = UIAlertAction(title: "封鎖使用者", style: .destructive) { [weak self] _ in
            
            let blockAlert = UIAlertController(
                title: "注意!",
                message: "將封鎖此使用者，未來將看不到該用戶相關資訊",
                preferredStyle: .alert
            )
            
            let blockConfirmAction = UIAlertAction(title: "封鎖", style: .destructive) { [weak self] _ in
                
                self?.viewModel.blockUser()
            }
            
            blockAlert.addAction(cancel)
            
            blockAlert.addAction(blockConfirmAction)
            
            self?.present(blockAlert, animated: true)
        }
        
        alert.addAction(blockAction)
        
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate and DataSource
extension ChatRoomMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.enableIQKeyboard()
        
        return viewModel.messageViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let userCell = tableView.dequeueReusableCell(
                withIdentifier: ChatRoomUserMessageCell.identifier, for: indexPath)
                as? ChatRoomUserMessageCell,
            let friendCell = tableView.dequeueReusableCell(
                withIdentifier: ChatRoomFriendMessageCell.identifier, for: indexPath)
                as? ChatRoomFriendMessageCell,
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
        
        viewModel.beginEditMessage()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        viewModel.changeMessage()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        viewModel.endEditMessage()
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChatRoomMessageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true)
        
        if
            let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            viewModel.changeContent(with: editedImage) { error in
                
                print(error)
            }
            
        } else if
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        
            viewModel.changeContent(with: image) { error in
                
                print(error)
            }
        }
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true)
            
        } else {

            showAlertWindow(title: "異常訊息", message: "你的裝置沒有相機喔！")
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
            
            showAlertWindow(title: "異常訊息", message: "你沒有打開開啟相簿權限喔！")
        }
    }
}


// Fix keyboard appear view will over the screen issue

//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

//@objc func keyboardWillShow(notification: NSNotification) {
//
//    let bottonGap = view.frame.height - view.safeAreaLayoutGuide.layoutFrame.height
//
//    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//        if self.view.frame.origin.y == 0 {
//            self.view.frame.origin.y -= keyboardSize.height + bottonGap
//        }
//    }
//}
//
//@objc func keyboardWillHide(notification: NSNotification) {
//    if self.view.frame.origin.y != 0 {
//        self.view.frame.origin.y = 0
//    }
//}

