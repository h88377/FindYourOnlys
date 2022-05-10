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
            
            tableView.allowsSelection = false
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.contentMode = .scaleAspectFill
            
            userImageView.tintColor = .white
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
    
    override var isEnableIQKeyboard: Bool { return false }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.startLoadingHandler = { [weak self] in

            self?.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            self?.stopLoading()
        }

        viewModel.fetchComments()
        
        checkCommentButton()
        
        setupKeyBoard()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                DispatchQueue.main.async {
                    
                    if
                        let firebaseError = error as? FirebaseError {
                        
                        self?.showAlertWindow(title: "異常", message: "\(firebaseError.errorMessage)")
                        
                    }
                }
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
        
//        viewModel.endEditCommentHandler = { [weak self] in
//            
//            self?.commentTextView.text = MessageType.placeHolder.rawValue
//
//            self?.commentTextView.textColor = UIColor.systemGray3
//            
//            self?.checkCommentButton()
//        }
        
        viewModel.beginEditCommentHander = { [weak self ] in
            
            if self?.commentTextView.textColor == UIColor.systemGray3 {
                
                self?.commentTextView.text = nil
                
                self?.commentTextView.textColor = UIColor.black
            }
        }
        
        viewModel.changeCommentHandler = { [weak self] in
            
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
        
        viewModel.blockHandler = { [weak self] senderViewModel in
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser,
                currentUser.id != senderViewModel.user.id
                    
            else {
                
                self?.showAlertWindow(title: "無法封鎖自己喔！", message: nil)
                
                return
            }
            
            self?.presentBlockActionSheet(with: senderViewModel)
        }
        
        viewModel.signInHandler = { [weak self] in
            
            self?.commentTextView.isEditable = false
            
            self?.commentTextView.text = "請先登入才能留言喔！"
            
            let storyboard = UIStoryboard.auth
            
            let authVC = storyboard.instantiateViewController(withIdentifier: AuthViewController.identifier)

            authVC.modalPresentationStyle = .custom
            
            authVC.transitioningDelegate = self

            self?.present(authVC, animated: true)
        }
        
    }
    
    func setupKeyBoard() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let screenHeight = UIScreen.main.bounds.height
        
        if
            let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                                as? NSValue)?.cgRectValue {
            
            if lroundf(Float(view.frame.origin.y)) == lroundf(Float((screenHeight)) * 0.4) {
                
                view.frame.origin.y -= (keyboardSize.height)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        
        let screenHeight = UIScreen.main.bounds.height
        
        if
            lroundf(Float(view.frame.origin.y)) != lroundf(Float((screenHeight)) * 0.4) {
            
            view.frame.origin.y = (screenHeight) * 0.4
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
    
    private func checkCommentButton() {
        
        if commentTextView.text != MessageType.placeHolder.rawValue
            && commentTextView.text?.isEmpty == false {
            
            sendButton.isEnabled = true
            
        } else {
            
            sendButton.isEnabled = false
        }
    }
    
    private func setupArticleContent() {
        
        userImageView.loadImage(viewModel.selectedAuthor?.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        nickNameLabel.text = viewModel.selectedAuthor?.nickName
        
        createdTimeLabel.text = viewModel.selectedArticle?.createdTime.formatedTime
        
        contentLabel.text = viewModel.selectedArticle?.content
    }
    
    private func presentBlockActionSheet(with senderViewModel: UserViewModel) {
        
        let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let blockAction = UIAlertAction(title: "封鎖留言使用者", style: .destructive) { [weak self] _ in
            
            let blockAlert = UIAlertController(
                title: "注意!",
                message: "將封鎖此留言的使用者，未來將看不到該用戶相關資訊",
                preferredStyle: .alert
            )
            
            let blockConfirmAction = UIAlertAction(title: "封鎖", style: .destructive) { [weak self] _ in
                
                self?.viewModel.blockUser(with: senderViewModel)
            }
            
            blockAlert.addAction(cancel)
            
            blockAlert.addAction(blockConfirmAction)
            
            self?.present(blockAlert, animated: true)
        }
        
        alert.addAction(blockAction)
        
        alert.addAction(cancel)
        
        // iPad specific code
        alert.popoverPresentationController?.sourceView = self.view
        
        let xOrigin = self.view.bounds.width / 2
        
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        
        alert.popoverPresentationController?.sourceRect = popoverRect
        
        alert.popoverPresentationController?.permittedArrowDirections = .up
        
        present(alert, animated: true)
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
        
        let commentViewModel = viewModel.commentViewModels.value[indexPath.row]
        
        let senderViewModel = viewModel.senderViewModels.value[indexPath.row]
        
        guard
            let commentCell = cell as? CommentCell
                
        else { return cell }
        
        commentCell.configure(
            with: commentViewModel,
            senderViewModel: senderViewModel)
        
        commentCell.blockHandler = { [weak self] in
            
            self?.viewModel.block(with: senderViewModel)
            
        }
        
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
        
        viewModel.changeMessage()
    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//
////        viewModel.endEditMessage()
//    }
}
