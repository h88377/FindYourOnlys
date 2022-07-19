//
//  AdoptFilterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/22.
//

import UIKit
import Lottie

class AdoptFilterViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = AdoptFilterViewModel()
    
    private let tableView = UITableView()
    
    private let filterButton = UIButton()
    
    private let animationView = AnimationView(name: LottieName.curiousCat.rawValue)
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Lift Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFilterButton()
        
        setupAnimationView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        filterButton.layer.cornerRadius = 15
    }
    
    // MARK: - Methods
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.backgroundColor = .projectBackgroundColor
        
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = false
        
        tableView.registerCellWithIdentifier(identifier: CityPickerCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: KindSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: FilterRemindCell.identifier)
        
        view.addSubview(tableView)
        
        view.addSubview(filterButton)
        
        view.addSubview(animationView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            
            tableView.bottomAnchor.constraint(equalTo: filterButton.topAnchor)])
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "搜尋條件"
        
        let filterButtonItem = UIBarButtonItem(title: "清除條件", style: .done, target: self, action: #selector(clear))
        
        navigationItem.rightBarButtonItem = filterButtonItem
    }
    
    private func setupFilterButton() {
        
        filterButton.setTitle("篩選", for: .normal)
        
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        filterButton.setTitleColor(.white, for: .normal)
        
        filterButton.setTitleColor(UIColor.projectIconColor2, for: .highlighted)
        
        filterButton.backgroundColor = .projectIconColor1
        
        filterButton.tintColor = .white
        
        filterButton.addTarget(self, action: #selector(filter), for: .touchUpInside)
        
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            filterButton.widthAnchor.constraint(equalToConstant: 150),
            
            filterButton.heightAnchor.constraint(equalToConstant: 60)])
    }
    
    private func setupAnimationView() {
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        animationView.play()
        
        animationView.loopMode = .loop
        
        NSLayoutConstraint.activate([
            
            animationView.heightAnchor.constraint(equalToConstant: 150),
            
            animationView.bottomAnchor.constraint(equalTo: filterButton.bottomAnchor),
            
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            animationView.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor)])
    }
    
    @objc func clear(sender: UIBarButtonItem) {
        
        viewModel.adoptFilterCondition = AdoptFilterCondition()
        
        tableView.reloadData()
    }
    
    @objc func filter(sender: UIButton) {
        
        guard let adoptVC = navigationController?.viewControllers[0] as? AdoptViewController,
              viewModel.isValidCondition else {
                  
                  AlertWindowManager.shared.showAlertWindow(at: self, title: "提醒", message: "請至少填寫一個條件喔！")
                  
                  return
              }
        
        adoptVC.adoptListVC?.viewModel.resetFilterCondition()
        
        adoptVC.adoptListVC?.viewModel.filteredCondition.value = viewModel.adoptFilterCondition
        
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
            
            guard let basicCell = cell as? BasePublishCell else { return cell }
            
            basicCell.delegate = self
            
            basicCell.selectionStyle = .none
            
            return basicCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterRemindCell.identifier, for: indexPath)
            
            guard let remindCell = cell as? FilterRemindCell else { return cell }
            
            remindCell.configureCell(with: .allowOneCondition)
            
            return remindCell
        }
    }
}

// MARK: - BasePublishCellDelegate

extension AdoptFilterViewController: BasePublishCellDelegate {
    
    func didChangeCity(_ cell: BasePublishCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangePetKind(_ cell: BasePublishCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeSex(_ cell: BasePublishCell, with sex: String) {
        
        viewModel.sexChanged(with: sex == Sex.male.rawValue ? "M" : "F")
    }
    
    func didChangeColor(_ cell: BasePublishCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
}
