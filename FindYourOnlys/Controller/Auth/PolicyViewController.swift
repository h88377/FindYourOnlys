//
//  PolicyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/8.
//

import UIKit
import WebKit

class PolicyViewController: UIViewController {
    
    var viewModel: PolicyViewModel?
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard
            let viewModel = viewModel,
            let policyURL = URL(string: viewModel.urlString)
                
        else { return }
        
        let myRequest = URLRequest(url: policyURL)
        
        webView.load(myRequest)
    }
    
}
