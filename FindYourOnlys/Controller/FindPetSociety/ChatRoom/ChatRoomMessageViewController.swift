//
//  ChatRoomThreadViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit
//import IQKeyboardManagerSwift

class ChatRoomMessageViewController: BaseViewController {
    
    private enum MessageType: String {
        
        case placeHolder = "請輸入訊息"
        
//        case empty = ""
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
            ? .systemBlue
            : .gray
        }
    }
    
    let viewModel = ChatRoomMessageViewModel()
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenIQKeyboardToolBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchMessage { error in
            
            if error != nil { print(error) }
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
        
        viewModel.editMessageHandler = { [weak self] in
            
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
        
        tableView.registerCellWithIdentifier(identifier: ChatRoomMessageCell.identifier)
        
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
}

// MARK: - UITableViewDelegate and DataSource
extension ChatRoomMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.enableIQKeyboard()
        
        return viewModel.messageViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomMessageCell.identifier, for: indexPath) as? ChatRoomMessageCell,
            let selectedFriend = viewModel.selectedFriend
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.messageViewModels.value[indexPath.row]
        
        cell.configureCell(with: cellViewModel, friend: selectedFriend)
        
        return cell
    }
}


// MARK: - UITextViewDelegate
extension ChatRoomMessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        viewModel.beginEditMessage()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        viewModel.editMessage()
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

