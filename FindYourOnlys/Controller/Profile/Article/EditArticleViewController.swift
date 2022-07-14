//
//  EditArticleViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import Foundation
import UIKit

class EditArticleViewController: BaseViewController {
    
    // MARK: - Properties
    
    var viewModel = EditArticleViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self,
                let error = errorViewModel?.error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel.checkEditedContentHandler = { [weak self] isValidContent, isValidDetectResult in
            
            guard let self = self else { return }
            
            if !isValidContent {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "注意", message: "請完整填寫內容再更新文章喔！")
                
            } else if !isValidDetectResult {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "注意", message: "請先通過動物照片辨識再發布文章喔！")
            }
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.popBack()
        }
        
        setupScanningHandler()
    }
    
    // MARK: - Methods
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: KindSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: CityPickerCell.identifier)
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        let barButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(edit))
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    private func setupScanningHandler() {
        
        viewModel.startScanningHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.startScanning()
        }
        
        viewModel.stopScanningHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.stopScanning()
        }
        
        viewModel.successHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.success()
        }
        
        viewModel.imageDetectHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.viewModel.detectImage()
        }
    }
    
    override func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in
            
            guard let self = self else { return }

            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.stopLoading()
        }
    }
    
    @objc func edit(sender: UIBarButtonItem) {
        
        viewModel.tapEdit()
    }
    
    private func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true)
            
        } else {

            AlertWindowManager.shared.showAlertWindow(at: self, title: "異常", message: "你的裝置沒有相機喔！")
        }
    }
    
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true)
            
        } else {
            
            AlertWindowManager.shared.showAlertWindow(at: self, title: "異常", message: "你沒有打開開啟相簿權限喔！")
        }
    }
}

// MARK: - UITableViewDelegate and DataSource
extension EditArticleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.editContentCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = viewModel.editContentCategory[indexPath.row]
        
        let cell = category.cellForIndexPath(indexPath, tableView: tableView, article: viewModel.article)
        
        guard let editCell = cell as? BasePublishCell else { return cell }
        
        editCell.delegate = self
        
        editCell.galleryHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.openGallery()
            
            self.viewModel.updateImageHandler = { image in
                
                editCell.layoutCellWith(image: image)
            }
        }
        
        editCell.cameraHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.openCamera()
            
            self.viewModel.updateImageHandler = { image in
                
                editCell.layoutCellWith(image: image)
            }
        }
        
        editCell.imageDetectHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.viewModel.imageDetectHandler?()
        }
        
        return editCell
    }
}

// MARK: - BasePublishCellDelegate

extension EditArticleViewController: BasePublishCellDelegate {
    
    func didChangeCity(_ cell: BasePublishCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: BasePublishCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePostType(_ cell: BasePublishCell, with postType: String) {
        
        viewModel.postTypeChanged(with: postType)
    }
    
    func didChangePetKind(_ cell: BasePublishCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeContent(_ cell: BasePublishCell, with content: String) {
        
        viewModel.contentChanged(with: content)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditArticleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        
        dismiss(animated: true)
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            viewModel.updateImageHandler?(editedImage)
            
            viewModel.selectedImage = editedImage
            
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            viewModel.updateImageHandler?(image)
            
            viewModel.selectedImage = image
        }
    }
}
