//
//  PetSocietyCommentViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import UIKit

class PetSocietyCommentViewController: BaseModalViewController {
    
    private enum MessageType: String {
        
        case placeHolder = "請輸入訊息"
    }
    
    @IBOutlet weak var commentTextView: UITextView! {
        
        didSet {
            
            commentTextView.delegate = self
            
            commentTextView.text = MessageType.placeHolder.rawValue
            
            commentTextView.textColor = UIColor.systemGray3
            
            commentTextView.layer.borderWidth = 1
            
            commentTextView.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    @IBOutlet weak var sendButton: UIButton! {
        
        didSet {
            
            sendButton.tintColor = sendButton.isEnabled
            ? .systemBlue
            : .gray
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    let viewModel = PetSocietyCommentViewModel()
    
    override var isHiddenIQKeyboardToolBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchComments()
        
        checkCommentButton()
        
        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error == nil
                    
            else {
                
                print(errorViewModel?.error)
                
                return
            }
        }
        
        viewModel.senderViewModels.bind { [weak self] _ in
            
            guard
                let self = self,
                self.viewModel.commentViewModels.value.count == self.viewModel.senderViewModels.value.count
                    
            else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                    
                self.viewModel.scrollToBottom()
            }
        }
        
        viewModel.commentViewModels.bind { [weak self] _ in
            
            guard
                let self = self,
                self.viewModel.commentViewModels.value.count == self.viewModel.senderViewModels.value.count
                    
            else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        }
        
        viewModel.endEditCommentHandler = { [weak self] in
            
            self?.commentTextView.text = MessageType.placeHolder.rawValue

            self?.commentTextView.textColor = UIColor.systemGray3
            
            self?.checkCommentButton()
        }
        
        viewModel.beginEditCommentHander = { [weak self ] in
            
            if self?.commentTextView.textColor == UIColor.systemGray3 {
                
                self?.commentTextView.text = nil
                
                self?.commentTextView.textColor = UIColor.black
            }
        }
        
        viewModel.editCommentHandler = { [weak self] in
            
            self?.checkCommentButton()
            
            if self?.commentTextView.textColor == UIColor.systemGray3 {
                
                self?.commentTextView.textColor = UIColor.black
            }
        }
        
        viewModel.scrollToBottomHandler = { [weak self] in
            
            guard
                let commentCount = self?.viewModel.commentViewModels.value.count,
                commentCount > 0
                    
            else { return }
            
            let indexPath = IndexPath(row: commentCount - 1, section: 0)
            
            self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        commentTextView.layer.cornerRadius = 5
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: CommentCell.identifier)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        viewModel.changedContent(with: commentTextView.text)
        
        viewModel.leaveComment()
        
        commentTextView.text = ""

        commentTextView.textColor = UIColor.systemGray3

        checkCommentButton()
    }
    
    func checkCommentButton() {
        
        if commentTextView.text != MessageType.placeHolder.rawValue
            && commentTextView.text?.isEmpty == false {
            
            sendButton.isEnabled = true
            
        } else {
            
            sendButton.isEnabled = false
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension PetSocietyCommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard
             viewModel.commentViewModels.value.count == viewModel.senderViewModels.value.count
                
        else { return 0 }
        
        return viewModel.commentViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath)
        
        guard
            let commentCell = cell as? CommentCell
                
        else { return cell }
        
        commentCell.configure(with: viewModel.commentViewModels.value[indexPath.row], senderViewModel: viewModel.senderViewModels.value[indexPath.row])
        
        return commentCell
    }
}

// MARK: - UITextViewDelegate
extension PetSocietyCommentViewController: UITextViewDelegate {
    
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
