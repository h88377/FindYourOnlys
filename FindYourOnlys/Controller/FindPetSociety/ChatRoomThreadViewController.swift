//
//  ChatRoomThreadViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit

class ChatRoomThreadViewController: BaseViewController {
    
    @IBOutlet weak var messageTextField: ContentInsetTextField!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    let viewModel = ChatRoomThreadViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchThread { error in
            
            if error != nil { print(error) }
        }
        
        viewModel.threadViewModels.bind { [weak self] _ in
            
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
    }
}

// MARK: - UITableViewDelegate and DataSource
extension ChatRoomThreadViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.threadViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomMessageCell.identifier, for: indexPath) as? ChatRoomMessageCell,
            let selectedFriendImageURLString = viewModel.selectedFriendURLString
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.threadViewModels.value[indexPath.row]
        
        cell.configureCell(with: cellViewModel, friendImageURLString: selectedFriendImageURLString)
        
        return cell
    }
}
