//
//  FindPetSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class FindPetSocietyViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    

    func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: FindPetSocietyTableViewCell.identifier)
        
    }
    @IBAction func addArticle(_ sender: UIButton) {
    }
    
}

// MARK: - UITableViewDataSource and Delegate
extension FindPetSocietyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FindPetSocietyTableViewCell.identifier, for: indexPath) as? FindPetSocietyTableViewCell
                
        else { return UITableViewCell() }
        
        
        return cell
    }
}
