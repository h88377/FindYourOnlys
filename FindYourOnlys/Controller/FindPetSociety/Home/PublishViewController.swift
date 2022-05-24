//
//  PublishViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = PublishViewModel()
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
            
            tableView.separatorStyle = .none
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        viewModel.checkPublishedContentHandler = { [weak self] isValidContent, isValidDetectResult in
            
            guard
                let self = self else { return }
            
            if !isValidContent {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "注意", message: "請完整填寫內容再發布文章喔！")
                
            } else if !isValidDetectResult {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "注意", message: "請先通過動物照片辨識再發布文章喔！")
            }
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.popBack()
        }
        
        setupScanningHandler()
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: KindSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: CityPickerCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
    }
    
    override func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }

            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.stopLoading()
        }
    }
    
    private func setupScanningHandler() {
        
        viewModel.startScanningHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.startScanning()
        }
        
        viewModel.stopScanningHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.stopScanning()
        }
        
        viewModel.successHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.success()
        }
        
        viewModel.imageDetectHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.viewModel.detectImage()
        }
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
    
    @IBAction func publish(_ sender: UIBarButtonItem) {
        
        viewModel.tapPublish()
    }
}

// MARK: - UITableViewDelegate and DataSource
extension PublishViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let publishContentCategory = viewModel.publishContentCategory

        return publishContentCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let publishContentCategory = viewModel.publishContentCategory
        
        let cell = publishContentCategory[indexPath.row].cellForIndexPath(
            indexPath,
            tableView: tableView,
            article: viewModel.article
        )
        
        guard
            let publishCell = cell as? BasePublishCell else { return cell }
        
        publishCell.delegate = self
        
        publishCell.galleryHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.openGallery()
            
            self.viewModel.updateImageHandler = { image in
                
                publishCell.layoutCellWith(image: image)
            }
        }
        
        publishCell.cameraHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.openCamera()
            
            self.viewModel.updateImageHandler = { image in
                
                publishCell.layoutCellWith(image: image)
            }
        }
        
        publishCell.imageDetectHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.viewModel.imageDetectHandler?()
        }
        
        return publishCell
    }
    
}

// MARK: - BasePublishCellDelegate

extension PublishViewController: BasePublishCellDelegate {
    
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
extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        
        dismiss(animated: true)
        
        if
            let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            viewModel.updateImageHandler?(editedImage)
            
            viewModel.selectedImage = editedImage
            
        } else if
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            viewModel.updateImageHandler?(image)
            
            viewModel.selectedImage = image
        }
    }
}
