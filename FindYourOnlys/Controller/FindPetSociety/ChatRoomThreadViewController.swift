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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatRoomMessageCell.identifier, for: indexPath) as? ChatRoomMessageCell
                
        else { return UITableViewCell() }
        
        return cell
    }
}
