//
//  BaseViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitle()
        
        setupTableView()
        
        setupCollectionView()
    }
    
    func setupNavigationTitle() {

        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemBlue]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes

//        navigationController?.navigationBar.backgroundColor = .systemPurple
        
    }
    
    func setupTableView() {
        
        
    }
    
    func setupCollectionView() {
        
        
    }
}
