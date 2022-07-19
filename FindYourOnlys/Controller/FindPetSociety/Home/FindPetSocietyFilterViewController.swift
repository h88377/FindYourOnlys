//
//  PetSocietyFilterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit
import Lottie

class FindPetSocietyFilterViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = FindPetSocietyFilterViewModel()
    
    private let tableView = UITableView()
    
    private let filterButton = UIButton()
    
    private let animationView = AnimationView(name: LottieName.curiousCat.rawValue)
    
    override var hidesBottomBarWhenPushed: Bool {
        
        get {
            return navigationController?.topViewController == self
        }
        set {
            super.hidesBottomBarWhenPushed = newValue
        }
    }
    
    // MARK: - View Life Cycle
    
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
        
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = false
        
        tableView.backgroundColor = .projectBackgroundColor
        
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
    
    func setupFilterButton() {
        
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
    
    func setupAnimationView() {
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        animationView.play()
        
        animationView.loopMode = .loop
        
        NSLayoutConstraint.activate([
            
            animationView.heightAnchor.constraint(equalToConstant: 150),
            
            animationView.bottomAnchor.constraint(equalTo: filterButton.bottomAnchor),
            
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            animationView.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor)])
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "搜尋條件"
        
        let filterButtonItem = UIBarButtonItem(title: "清除條件", style: .done, target: self, action: #selector(clear))
        
        navigationItem.rightBarButtonItem = filterButtonItem
    }
    
    @objc func clear(sender: UIBarButtonItem) {
        
        viewModel.findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
        
        tableView.reloadData()
    }
    
    @objc func filter(sender: UIButton) {
        
        guard let petSocietyVC = navigationController?.viewControllers[0] as? FindPetSocietyViewController,
              viewModel.isValidCondition
        else {
            
            AlertWindowManager.shared.showAlertWindow(at: self, title: "請填寫全部條件喔！")
            
            return
        }
        
        petSocietyVC.viewModel.fetchFindArticles(with: viewModel.findPetSocietyFilterCondition)
        
        petSocietyVC.viewModel.findPetSocietyFilterCondition = viewModel.findPetSocietyFilterCondition
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource and Delegate

extension FindPetSocietyFilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.findPetSocietyFilterCategory.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row + 1 <= viewModel.findPetSocietyFilterCategory.count {
            
            let cell = viewModel.findPetSocietyFilterCategory[indexPath.row].cellForIndexPath(
                indexPath,
                tableView: tableView,
                findCondition: viewModel.findPetSocietyFilterCondition)
            
            guard let baseCell = cell as? BasePublishCell else { return cell }
            
            baseCell.delegate = self
            
            return baseCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterRemindCell.identifier, for: indexPath)
            
            guard let remindCell = cell as? FilterRemindCell else { return cell }
            
            remindCell.configureCell(with: .allCondition)
            
            return remindCell
        }
    }
}

// MARK: - BasePublishCellDelegate

extension FindPetSocietyFilterViewController: BasePublishCellDelegate {
    
    func didChangeCity(_ cell: BasePublishCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: BasePublishCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePetKind(_ cell: BasePublishCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangePostType(_ cell: BasePublishCell, with postType: String) {
        
        viewModel.postTypeChanged(with: postType)
    }
}
