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
            ? .projectIconColor1
            : .projectPlaceHolderColor
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.textColor = .white
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var createdTimeLabel: UILabel! {
        
        didSet {
            
            createdTimeLabel.textColor = .white
            
            createdTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel! {
        
        didSet {
            
            contentLabel.textColor = .white
            
            contentLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectIconColor1
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
        
        viewModel.senderViewModels.bind { [weak self] senderViewModels in
            
            guard
                let self = self,
                self.viewModel.commentViewModels.value.count == self.viewModel.senderViewModels.value.count
                    
            else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                self.setupArticleContent()
                    
                self.viewModel.scrollToBottom()
                
                self.tableView.isHidden = senderViewModels.count == 0
            }
        }
        
        viewModel.commentViewModels.bind { [weak self] _ in
            
            guard
                let self = self,
                self.viewModel.commentViewModels.value.count == self.viewModel.senderViewModels.value.count
                    
            else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                self.setupArticleContent()
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
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        
        commentTextView.centerVertically()
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: CommentCell.identifier)
        
//        tableView.registerViewWithIdentifier(identifier: CommentHeaderView.identifier)
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
    
    func setupArticleContent() {
        
        userImageView.loadImage(viewModel.selectedAuthor?.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        nickNameLabel.text = viewModel.selectedAuthor?.nickName
        
        createdTimeLabel.text = viewModel.selectedArticle?.createdTime.formatedTime
        
        contentLabel.text = viewModel.selectedArticle?.content
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
        
        commentCell.configure(
            with: viewModel.commentViewModels.value[indexPath.row],
            senderViewModel: viewModel.senderViewModels.value[indexPath.row])
        
        return commentCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: CommentHeaderView.identifier)
                as? CommentHeaderView,
            let selectedArticle = viewModel.selectedArticle,
            let selectedAuthor = viewModel.selectedAuthor
                
        else { return nil }
        
        headerView.configureView(with: selectedArticle, author: selectedAuthor)
        
        return headerView
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
