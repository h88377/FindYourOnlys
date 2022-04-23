//
//  ShareSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class ShareSocietyViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

    @IBAction func publish(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.shareSociety
        
        let shareSocietyVC = storyboard.instantiateViewController(withIdentifier: SharePublishViewController.identifier)
        
        navigationController?.pushViewController(shareSocietyVC, animated: true)
    }
    
}
