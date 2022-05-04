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
        
        viewModel.changeCommentHandler = { [weak self] in
            
            self?.checkCommentButton()
            
            if self?.commentTextView.textColor == UIColor.systemGray3 {
                
                self?.commentTextView.textColor = UIColor.black
            }
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        viewModel.endEditMessage()
    }
}
