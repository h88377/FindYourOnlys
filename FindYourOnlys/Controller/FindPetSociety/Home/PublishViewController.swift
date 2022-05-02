//
//  PublishViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishViewController: BaseViewController {
    
    let viewModel = PublishViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
            
            tableView.separatorStyle = .none
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.checkPublishedContent = { [weak self] isValid in
            
            if !isValid {
                
                self?.showAlertWindow(title: "文章內容不足", message: "請完整填寫內容再發布文章喔！")
            }
        }
        
        viewModel.startLoadingHandler = { [weak self] in

            guard
                let self = self else { return }
            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.startLoading(at: self.view)
            }
        }
        
        viewModel.stopLoadingHandler = {

            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.stopLoading()
            }
        }
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
    }
    
    @IBAction func publish(_ sender: UIBarButtonItem) {
        
        viewModel.tapPublish { [weak self] error in
            
            if error != nil {
                
                print(error)
                
                return
            }
            
            self?.navigationController?.popViewController(animated: true)
        }
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
        
        guard
            let cell = publishContentCategory[indexPath.row]
                .cellForIndexPath(indexPath, tableView: tableView)
                as? PublishBasicCell
                
        else { return UITableViewCell() }
        
        cell.delegate = self
        
        cell.galleryHandler = { [weak self] in
            
            self?.openGallery()
            
            self?.viewModel.updateImage = { image in
                
                cell.layoutCellWith(image: image)
            }
        }
        
        cell.cameraHandler = { [weak self] in
            
            self?.openCamera()
            
            self?.viewModel.updateImage = { image in
                
                cell.layoutCellWith(image: image)
            }
        }
        return cell
    }
    
}

// MARK: - PublishSelectionCellDelegate
extension PublishViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePostType(_ cell: PublishBasicCell, with postType: String) {
        
        viewModel.postTypeChanged(with: postType)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeContent(_ cell: PublishBasicCell, with content: String) {
        
        viewModel.contentChanged(with: content)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension PublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true)
        
        if
            let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            viewModel.updateImage?(editedImage)
            
            viewModel.selectedImage = editedImage
            
        } else if
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            viewModel.updateImage?(image)
            
            viewModel.selectedImage = image
        }
    }
    
    func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true)
            
        } else {

            showAlertWindow(title: "異常訊息", message: "你的裝置沒有相機喔！")
        }
        
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            
            imagePicker.allowsEditing = true
            
            present(imagePicker, animated: true)
            
        } else {
            
            showAlertWindow(title: "異常訊息", message: "你沒有打開開啟相簿權限喔！")
        }
    }
}
