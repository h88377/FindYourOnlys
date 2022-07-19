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
    
    // MARK: - Properties
    
    let viewModel = PetSocietyCommentViewModel()
    
    @IBOutlet private weak var commentTextView: UITextView! {
        
        didSet {
            
            commentTextView.delegate = self
            
            commentTextView.text = MessageType.placeHolder.rawValue
            
            commentTextView.textColor = UIColor.systemGray3
            
            commentTextView.layer.borderWidth = 1
            
            commentTextView.layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    @IBOutlet private weak var sendButton: UIButton! {
        
        didSet {
            
            sendButton.tintColor = sendButton.isEnabled
            ? .projectIconColor1
            : .projectPlaceHolderColor
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
            
            tableView.allowsSelection = false
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet private weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.contentMode = .scaleAspectFill
            
            userImageView.tintColor = .white
        }
    }
    
    @IBOutlet private weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.textColor = .white
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet private weak var createdTimeLabel: UILabel! {
        
        didSet {
            
            createdTimeLabel.textColor = .white
            
            createdTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    @IBOutlet private weak var contentLabel: UILabel! {
        
        didSet {
            
            contentLabel.textColor = .white
            
            contentLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectIconColor1
        }
    }
    
    override var isHiddenIQKeyboardToolBar: Bool { return true }
    
    override var isEnableIQKeyboard: Bool { return false }
    
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
        
        viewModel.commentSenders.bind { [weak self] commentSenders in
            
            guard
                let self = self,
                self.viewModel.comments.value.count == self.viewModel.commentSenders.value.count
            else { return }
            
            self.tableView.reloadData()
            
            self.setupArticleContent()
                
            self.scrollToBottomIfHasComment()
            
            self.tableView.isHidden = commentSenders.isEmpty
        }
        
        viewModel.comments.bind { [weak self] _ in
            
            guard
                let self = self,
                self.viewModel.comments.value.count == self.viewModel.commentSenders.value.count
            else { return }
                
            self.tableView.reloadData()
            
            self.setupArticleContent()
        }
        
        viewModel.signInHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.commentTextView.isEditable = false
            
            self.commentTextView.text = "請先登入才能留言喔！"
            
            let storyboard = UIStoryboard.auth
            
            let authVC = storyboard.instantiateViewController(withIdentifier: AuthViewController.identifier)

            authVC.modalPresentationStyle = .custom
            
            authVC.transitioningDelegate = self

            self.present(authVC, animated: true)
        }
        
        viewModel.beginEditCommentHander = { [weak self ] in
            
            guard let self = self else { return }
            
            if self.commentTextView.textColor == UIColor.systemGray3 {
                
                self.commentTextView.text = nil
                
                self.commentTextView.textColor = UIColor.black
            }
        }

        setupKeyBoard()
        
        viewModel.fetchComments()
        
        checkCommentButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        commentTextView.layer.cornerRadius = 5
        
        userImageView.makeRound()
        
        commentTextView.centerVertically()
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: CommentCell.identifier)
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
    
    private func scrollToBottomIfHasComment() {
        
        let commentCount = viewModel.comments.value.count
        
        guard commentCount > 0 else { return }
        
        let indexPath = IndexPath(row: commentCount - 1, section: 0)
        
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    private func checkCommentButton() {
        
        if commentTextView.text != MessageType.placeHolder.rawValue &&
            commentTextView.text?.isEmpty == false {
            
            sendButton.isEnabled = true
            
        } else {
            
            sendButton.isEnabled = false
        }
    }
    
    private func setupArticleContent() {
        
        let selectedAuthor = viewModel.selectedAuthor
        
        let selectedArticle = viewModel.selectedArticle
        
        userImageView.loadImage(
            selectedAuthor?.imageURLString,
            placeHolder: UIImage.system(.personPlaceHolder))
        
        nickNameLabel.text = selectedAuthor?.nickName
        
        createdTimeLabel.text = selectedArticle?.createdTime.formatedTime
        
        contentLabel.text = selectedArticle?.content
    }
    
    private func setupKeyBoard() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        
        let screenHeight = UIScreen.main.bounds.height
        
        let originY = view.frame.origin.y
        
        if let keyboardSize = (
            notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if CGFloatToInt(originY) == CGFloatToInt(screenHeight * 0.4) {
                
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        
        let screenHeight = UIScreen.main.bounds.height
        
        let originY = view.frame.origin.y
        
        if CGFloatToInt(originY) != CGFloatToInt(screenHeight * 0.4) {
            
            view.frame.origin.y = screenHeight * 0.4
        }
    }
    
    private func CGFloatToInt(_ number: CGFloat) -> Int {
        
        return lroundf(Float(number))
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        
        viewModel.changedContent(with: commentTextView.text)
        
        viewModel.leaveComment()
        
        commentTextView.text = ""

        commentTextView.textColor = UIColor.systemGray3

        checkCommentButton()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension PetSocietyCommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard viewModel.comments.value.count == viewModel.commentSenders.value.count else {
            
            return 0
        }
        
        return viewModel.comments.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.identifier, for: indexPath)
        
        let comment = viewModel.comments.value[indexPath.row]
        
        let commentSender = viewModel.commentSenders.value[indexPath.row]
        
        guard let commentCell = cell as? CommentCell else { return cell }
        
        commentCell.configure(
            with: comment,
            sender: commentSender)
        
        commentCell.blockHandler = { [weak self] in
            
            guard let self = self else { return }
            
            let blockConfirmAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
                
                self.viewModel.blockUser(with: commentSender)
            }
            
            AlertWindowManager.shared.presentBlockActionSheet(at: self, with: blockConfirmAction)
        }
        
        return commentCell
    }
}

// MARK: - UITextViewDelegate
extension PetSocietyCommentViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        viewModel.beginEditMessage()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        checkCommentButton()
        
        if commentTextView.textColor == UIColor.systemGray3 {
            
            commentTextView.textColor = UIColor.black
        }
    }
}
