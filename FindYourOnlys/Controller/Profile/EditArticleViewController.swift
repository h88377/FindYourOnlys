//
//  EditArticleViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/29.
//

import Foundation
import UIKit

class EditArticleViewController: BaseViewController {
    
    var viewModel = EditArticleViewModel()
    
//    init(model: EditArticleViewModel) {
//        super.init()
//
//        self.viewModel = model
//    }
    
    

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet{
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.checkEditedContent = { [weak self] isValid in
            
            if !isValid {
                
                self?.showAlertWindow(title: "文章內容不足", message: "請完整填寫內容再更新文章喔！")
            }
            
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            DispatchQueue.main.async {
                
                self?.navigationController?.popViewController(animated: true)
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
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        let barButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(edit))
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    @objc func edit(sender: UIBarButtonItem) {
        
        viewModel.tapEdit()
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
        
        guard
            let editCell = cell as? PublishBasicCell else { return cell }
        
        editCell.delegate = self
        
        editCell.galleryHandler = { [weak self] in
            
            self?.openGallery()
            
            self?.viewModel.updateImage = { image in
                
                editCell.layoutCellWith(image: image)
            }
        }
        
        editCell.cameraHandler = { [weak self] in
            
            self?.openCamera()
            
            self?.viewModel.updateImage = { image in
                
                editCell.layoutCellWith(image: image)
            }
        }
        
        return editCell
        
    }
}

// MARK: - PublishSelectionCellDelegate
extension EditArticleViewController: PublishBasicCellDelegate {
    
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
extension EditArticleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

