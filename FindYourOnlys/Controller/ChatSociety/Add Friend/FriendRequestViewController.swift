//
//  FriendRequestViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class FriendRequestViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    let viewModel = FriendRequestViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchFriendRequestList()
        
        viewModel.friendRequestListViewModels.bind { [weak self] friendRequestViewModels in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.isHidden = friendRequestViewModels.flatMap { $0.friendRequestList.users }.count == 0
                
                self.tableView.reloadData()
            }
        }
        
        viewModel.errorViewModel?.bind(listener: { [weak self] errorViewModel in
            
            DispatchQueue.main.async {
                
                self?.showAlertWindow(title: "異常", message: "\(errorViewModel.error)")
            }
        })
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: FriendRequestCell.identifier)
        
        tableView.registerViewWithIdentifier(identifier: FriendRequestHeaderView.identifier)
    }
    
}

// MARK: - UITableViewDelegate and DataSource
extension FriendRequestViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        viewModel.friendRequestListViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.friendRequestListViewModels.value[section].friendRequestList.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendRequestCell.identifier, for: indexPath) as? FriendRequestCell
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.friendRequestListViewModels.value[indexPath.section]
        
        cell.configureCell(with: cellViewModel.friendRequestList.type, user: cellViewModel.friendRequestList.users[indexPath.row])
        
        cell.acceptHandler = { [weak self] in
            
            self?.viewModel.acceptFriendRequest(at: indexPath)
            
        }
        
        cell.rejectHandler = { [weak self] in
            
            self?.viewModel.removeFriendRequest(at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: FriendRequestHeaderView.identifier)
        
        guard
            let headerView = view as? FriendRequestHeaderView else { return view }
        
        headerView.configureView(with: viewModel.friendRequestListViewModels.value[section].friendRequestList.type.rawValue)
        
        return headerView
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
//        return viewModel.friendRequestListViewModels.value[section].friendRequestList.type.rawValue
//    }
}
