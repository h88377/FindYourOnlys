//
//  ChatRoomThreadViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit
import IQKeyboardManagerSwift

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
        }
        
        checkMessageButton()
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
    
    @IBAction func openCamera(_ sender: UIButton) {
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        messageTextView.endEditing(true)
        
        guard
            messageTextView.text != MessageType.placeHolder.rawValue,
            messageTextView.text?.isEmpty == false
                
        else { return }
        
        viewModel.sendMessage { error in
            
            print(error)
        }
        
        messageTextView.text = MessageType.placeHolder.rawValue
        
        messageTextView.textColor = UIColor.systemGray3
        
        checkMessageButton()
    }
}

// MARK: - UITableViewDelegate and DataSource
extension ChatRoomMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messageViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomMessageCell.identifier, for: indexPath) as? ChatRoomMessageCell,
            let selectedFriendImageURLString = viewModel.selectedFriendURLString
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.messageViewModels.value[indexPath.row]
        
        cell.configureCell(with: cellViewModel, friendImageURLString: selectedFriendImageURLString)
        
        return cell
    }
}


// MARK: - UITextViewDelegate
extension ChatRoomMessageViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.systemGray3 {
            
            textView.text = nil
            
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        checkMessageButton()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            
            textView.text = MessageType.placeHolder.rawValue
            
            textView.textColor = UIColor.systemGray3
            
            return
        }
        
        viewModel.changedContent(with: textView.text)
        
    }
}
