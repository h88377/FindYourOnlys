//
//  SharePublishViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class SharePublishViewController: BaseViewController {
    
    let viewModel = SharePublishViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.finishPublishHandler = { [weak self] in
            
            self?.navigationController?.popViewController(animated: true)
        }
        
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
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        let publishItemButton = UIBarButtonItem(title: "發布", style: .plain, target: self, action: #selector(publish))
        
        navigationItem.rightBarButtonItem = publishItemButton
    }
    
    @objc func publish(sender: UIBarButtonItem) {
        
        viewModel.tapPublish()
    }
}

// MARK: - SharePublishViewController: UITableViewDelegate and DataSource
extension SharePublishViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.shareContentCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = viewModel.shareContentCategory[indexPath.row].cellForIndexPath(indexPath, tableView: tableView)
        
        guard
            let publishCell = cell as? PublishBasicCell else { return cell }
        
        publishCell.delegate = self
        
        publishCell.galleryHandler = { [weak self] in
            
            self?.openGallery()
            
            self?.viewModel.updateImage = { image in
                
                publishCell.layoutCellWith(image: image)
            }
        }
        
        publishCell.cameraHandler = { [weak self] in
            
            self?.openCamera()
            
            self?.viewModel.updateImage = { image in
                
                publishCell.layoutCellWith(image: image)
            }
        }
         
        return publishCell
    }
}

// MARK: - PublishSelectionCellDelegate
extension SharePublishViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeContent(_ cell: PublishBasicCell, with content: String) {
        
        viewModel.contentChanged(with: content)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension SharePublishViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    func openGallery(){
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
