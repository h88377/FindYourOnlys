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
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.friendRequestListViewModels.bind { [weak self] friendRequestViewModels in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.isHidden = friendRequestViewModels.flatMap { $0.friendRequestList.users }.count == 0
                
                self.tableView.reloadData()
            }
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
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
        
        let requestListCount = viewModel.friendRequestListViewModels.value.count
        
        return requestListCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let friendRequestCount = viewModel.friendRequestListViewModels.value[section].friendRequestList.users.count
        
        return friendRequestCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestCell.identifier, for: indexPath)
        
        guard
            let friendRequestCell = cell as? FriendRequestCell
                
        else { return cell }
        
        let cellViewModel = viewModel.friendRequestListViewModels.value[indexPath.section]
        
        let requestType = cellViewModel.friendRequestList.type
        
        let user = cellViewModel.friendRequestList.users[indexPath.row]
        
        friendRequestCell.configureCell(
            with: requestType,
            user: user
        )
        
        friendRequestCell.acceptHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.viewModel.acceptFriendRequest(at: indexPath)
            
        }
        
        friendRequestCell.rejectHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.viewModel.removeFriendRequest(at: indexPath)
        }
        
        return friendRequestCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendRequestHeaderView.identifier)
        
        guard
            let headerView = view as? FriendRequestHeaderView else { return view }
        
        let requestTypeText = viewModel.friendRequestListViewModels.value[section].friendRequestList.type.rawValue
        
        headerView.configureView(with: requestTypeText)
        
        return headerView
    }
}
