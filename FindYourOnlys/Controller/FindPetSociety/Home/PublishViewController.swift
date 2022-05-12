//
//  PublishViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit
import MLKit

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
        
        viewModel.checkPublishedContent = { [weak self] isValidContent, isValidDetectResult in
            
            if !isValidContent {
                
                self?.showAlertWindow(title: "注意", message: "請完整填寫內容再發布文章喔！")
                
            } else if !isValidDetectResult {
                
                self?.showAlertWindow(title: "注意", message: "請先通過動物照片辨識再發布文章喔！")
            }
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            DispatchQueue.main.async {
                
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.startLoadingHandler = { [weak self] in

            self?.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            self?.stopLoading()
        }
        
        enum ImageDetectDatabase: String, CaseIterable {
            
            case bird = "Bird"
            
            case pomacentridae = "Pomacentridae"
            
            case shetlandSheepdog = "Shetland sheepdog"
            
            case bear = "Bear"
            
            case cattle = "Cattle"
            
            case cat = "Cat"
            
            case dinosaur = "Dinosaur"
            
            case dragon = "Dragon"
            
            case jersey = "Jersey"
            
            case waterfowl = "Waterfowl"
            
            case cairnTerrier = "Cairn terrier"
            
            case horse = "Horse"
            
            case herd = "Herd"
            
            case insect = "Insect"
            
            case penguin = "Penguin"
            
            case pet = "Pet"
            
            case duck = "Duck"
            
            case turtle = "Turtle"
            
            case crocodile = "Crocodile"
            
            case dog = "Dog"
            
            case bull = "Bull"
            
            case butterfly = "Butterfly"
            
            case larva = "Larva"
            
            case sphynx = "Sphynx"
            
            case bassetHound = "Basset hound"
        }
        
        viewModel.imageDetectHandler = { [weak self] in
            
            guard
                let self = self,
                let selectedImage = self.viewModel.selectedImage
            
            else {
                
                self?.showAlertWindow(title: "注意", message: "請先選擇照片再進行辨識喔！")
                
                return
                
            }
            
            self.startLoading()
            
            let visionImage = VisionImage(image: selectedImage)
            
            visionImage.orientation = selectedImage.imageOrientation
            
            let options = ImageLabelerOptions()
            
            options.confidenceThreshold = 0.7
            
            let labeler = ImageLabeler.imageLabeler(options: options)
            
            labeler.process(visionImage) { labels, error in
                
                guard
                    error == nil,
                    let labels = labels
                        
                else {
                    
                    DispatchQueue.main.async {
                        
                        self.showAlertWindow(title: "異常", message: "圖片辨識失敗，請重新嘗試或換照片後再嘗試一次。")
                    }
                    
                    self.stopLoading()
                    
                    return
                }
                
                let imageDetectDatabase = ImageDetectDatabase.allCases.map { $0.rawValue }
                
                let isValidResult = labels.map { label in
                    
                    imageDetectDatabase.contains(label.text)
                    
                }.contains(true)
                
                self.viewModel.isValidDetectResult = isValidResult
                
                self.stopLoading()
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
        
        guard
            let cell = publishContentCategory[indexPath.row]
                .cellForIndexPath(indexPath, tableView: tableView, article: viewModel.article)
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
        
        cell.imageDetectHandler = { [weak self] in
            
            self?.viewModel.imageDetectHandler?()
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
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
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
