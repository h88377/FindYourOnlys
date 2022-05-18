//
//  AdoptFilterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/22.
//

import UIKit
import Lottie

class AdoptFilterViewController: BaseViewController {
    
    let tableView = UITableView()
    
    let filterButton = UIButton()
    
    let animationView = AnimationView(name: LottieName.curiousCat.rawValue)
    
    let viewModel = AdoptFilterViewModel()
    
    override var isHiddenTabBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFilterButton()
        
        setupAnimationView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        filterButton.layer.cornerRadius = 15
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.backgroundColor = .projectBackgroundColor
        
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = false
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: FilterRemindCell.identifier)
        
        view.addSubview(tableView)
        
        view.addSubview(filterButton)
        
        view.addSubview(animationView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
                
//                tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                
                tableView.bottomAnchor.constraint(equalTo: filterButton.topAnchor)
            ]
        )
    }
    
    func setupFilterButton() {
        
        filterButton.setTitle("篩選", for: .normal)
        
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        filterButton.setTitleColor(.white, for: .normal)
        
        filterButton.setTitleColor(UIColor.projectIconColor2, for: .highlighted)
        
        filterButton.backgroundColor = .projectIconColor1
        
        filterButton.tintColor = .white
        
        filterButton.addTarget(self, action: #selector(filter), for: .touchUpInside)
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                
                filterButton.widthAnchor.constraint(equalToConstant: 150),
                
                filterButton.heightAnchor.constraint(equalToConstant: 60)
            ]
        )
    }
    
    func setupAnimationView() {
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        animationView.play()
        
        animationView.loopMode = .loop
        
        NSLayoutConstraint.activate(
            [
                animationView.heightAnchor.constraint(equalToConstant: 150),
                
                animationView.bottomAnchor.constraint(equalTo: filterButton.bottomAnchor),
                
                animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                animationView.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor)
            ]
        )
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "搜尋條件"
        
        let filterButtonItem = UIBarButtonItem(title: "清除條件", style: .done, target: self, action: #selector(clear))
        
        navigationItem.rightBarButtonItem = filterButtonItem
    }
    
    @objc func clear(sender: UIBarButtonItem) {
        
        viewModel.adoptFilterCondition = AdoptFilterCondition()
        
        tableView.reloadData()
    }
    
    @objc func filter(sender: UIButton) {
        
        guard
            let adoptVC = navigationController?.viewControllers[0] as? AdoptViewController,
            viewModel.isValidCondition
                
        else {
            
            showAlertWindow(title: "異常訊息", message: "請至少填寫一個條件喔！")
            
            return
        }
        
        adoptVC.adoptListVC?.viewModel.resetFilterCondition()
        
        adoptVC.adoptListVC?.viewModel.filterConditionViewModel.value = viewModel.adoptFilterCondition
        
        adoptVC.adoptListVC?.viewModel.resetFetchPet()
        
        adoptVC.viewModel.adoptFilterCondition = viewModel.adoptFilterCondition
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource and Delegate
extension AdoptFilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.adoptFilterCategory.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let adoptFilterCategory = viewModel.adoptFilterCategory
        
        if indexPath.row + 1 <= adoptFilterCategory.count {
            
            let cell = adoptFilterCategory[indexPath.row].cellForIndexPath(
                indexPath,
                tableView: tableView,
                condition: viewModel.adoptFilterCondition
            )
            
            guard
                let basicCell = cell as? PublishBasicCell
                    
            else { return cell }
            
            basicCell.delegate = self
            
            basicCell.selectionStyle = .none
            
            return basicCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterRemindCell.identifier, for: indexPath)
            
            guard
                let remindCell = cell as? FilterRemindCell
            
            else { return cell }
            
            remindCell.configureCell(with: .allowOneCondition)
            
            return remindCell
        }
    }
}

extension AdoptFilterViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeSex(_ cell: PublishBasicCell, with sex: String) {
        
        if sex == Sex.male.rawValue {
            
            viewModel.sexChanged(with: "M")
            
        } else {
            
            viewModel.sexChanged(with: "F")
        }
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
    
        viewModel.colorChanged(with: color)
    }
    
}
