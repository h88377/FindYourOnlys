//
//  AddFriendViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import UIKit

class AddFriendViewController: BaseViewController {
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var qrCodeButton: UIButton!
    
    @IBOutlet weak var myQRCodeImageView: UIImageView!
    
    let viewModel = AddFriendViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.searchUserIdHander = { [weak self] in
            
            
        }
        
    }
    
    @IBAction func searchUserId(_ sender: UIButton) {
        
//        viewModel.searchUserId()
        
        let storyboard = UIStoryboard.findPetSociety
        
        let searchFriendVC = storyboard.instantiateViewController(withIdentifier: SearchFriendViewController.identifier)
        
        navigationController?.pushViewController(searchFriendVC, animated: true)
    }
    
    @IBAction func searchQRCode(_ sender: UIButton) {
    }
}
