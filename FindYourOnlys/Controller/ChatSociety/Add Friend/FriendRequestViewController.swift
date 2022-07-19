//
//  FriendRequestViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class FriendRequestViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = FriendRequestViewModel()
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    override var hidesBottomBarWhenPushed: Bool {
        
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.friendRequestLists.bind { [weak self] friendRequestLists in
            
            guard let self = self else { return }
            
            self.tableView.isHidden = friendRequestLists.flatMap { $0.users }.isEmpty
            
            self.tableView.reloadData()
        }
        
        viewModel.error.bind { [weak self] error in
            
            guard
                let self = self,
                let error = error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel.fetchFriendRequestList()
    }
    
    // MARK: - Methods
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: FriendRequestCell.identifier)
        
        tableView.registerViewWithIdentifier(identifier: FriendRequestHeaderView.identifier)
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "好友邀請"
    }
}

// MARK: - UITableViewDelegate and DataSource

extension FriendRequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let requestListCount = viewModel.friendRequestLists.value.count
        
        return requestListCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let friendRequestCount = viewModel
            .friendRequestLists
            .value[section]
            .users.count
        
        return friendRequestCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestCell.identifier, for: indexPath)
        
        guard let friendRequestCell = cell as? FriendRequestCell else { return cell }
        
        let friendRequestList = viewModel.friendRequestLists.value[indexPath.section]
        
        let requestType = friendRequestList.type
        
        let user = friendRequestList.users[indexPath.row]
        
        friendRequestCell.configureCell(
            with: requestType,
            user: user)
        
        friendRequestCell.acceptHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.viewModel.acceptFriendRequest(at: indexPath)
        }
        
        friendRequestCell.rejectHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.viewModel.removeFriendRequest(at: indexPath)
        }
        
        return friendRequestCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendRequestHeaderView.identifier)
        
        guard let headerView = view as? FriendRequestHeaderView else { return view }
        
        let requestTypeText = viewModel.friendRequestLists.value[section].type.rawValue
        
        headerView.configureView(with: requestTypeText)
        
        return headerView
    }
}
