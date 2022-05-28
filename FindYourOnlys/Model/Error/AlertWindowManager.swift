//
//  AlertWindowManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/19.
//

import UIKit

class AlertWindowManager {
    
    private init() {}
    
    static let shared = AlertWindowManager()
    
    func showAlertWindow(at controller: UIViewController, title: String, message: String? = nil) {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(action)
            
            controller.present(alert, animated: true)
        }
    }
    
    func showAlertWindow(at controller: UIViewController, of error: Error) {
        
        let message: String
        
        switch error {
            
        case let httpClientError as HTTPClientError:
            
            message = httpClientError.errorMessage
            
        case let googleMLError as GoogleMLError:
            
            message = googleMLError.errorMessage
            
        case let mapError as MapError:
            
            message = mapError.errorMessage
            
        case let authError as AuthError:
            
            message = authError.errorMessage
            
        case let firebaseError as FirebaseError:
            
            message = firebaseError.errorMessage
            
        case let localStorageError as LocalStorageError:
            
            message = localStorageError.errorMessage
            
        case let deleteDataError as DeleteDataError:
            
            message = deleteDataError.errorMessage
            
        case let deleteAccountError as DeleteAccountError:
            
            message = deleteAccountError.errorMessage
            
        default:
            
            message = "發生預期外的錯誤"
        }
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "異常", message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(action)
            
            controller.present(alert, animated: true)
        }
    }

    func presentBlockActionSheet(at controller: UIViewController, with blockConfirmAction: UIAlertAction) {

        let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)

        let cancel = UIAlertAction(title: "取消", style: .cancel)

        let blockAction = UIAlertAction(title: "封鎖使用者", style: .destructive) { _ in

            let blockAlert = UIAlertController(
                title: "注意!",
                message: "將封鎖此使用者，未來將看不到該用戶發布的資訊",
                preferredStyle: .alert
            )

            blockAlert.addAction(cancel)

            blockAlert.addAction(blockConfirmAction)

            controller.present(blockAlert, animated: true)
        }

        alert.addAction(blockAction)

        alert.addAction(cancel)

        // iPad specific code
        configureIpadAlert(at: controller, with: alert)

        controller.present(alert, animated: true)
    }
    
    func presentEditActionSheet(
        at controller: UIViewController,
        articleViewModel: ArticleViewModel,
        with deleteConfirmAction: UIAlertAction
    ) {
        
        let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let editAction = UIAlertAction(title: "編輯文章", style: .default) { _ in
            
            let storyboard = UIStoryboard.profile
            
            guard
                let editVC = storyboard.instantiateViewController(
                    withIdentifier: EditArticleViewController.identifier)
                    as? EditArticleViewController
            
            else { return }
            
            let article = articleViewModel.article
            
            editVC.viewModel.article = article
            
            controller.navigationController?.pushViewController(editVC, animated: true)
        }
        
        let deleteAction = UIAlertAction(title: "刪除文章", style: .destructive) { _ in
            
            let deleteAlert = UIAlertController(title: "注意!", message: "將刪除此篇文章", preferredStyle: .alert)
            
            deleteAlert.addAction(cancel)
            
            deleteAlert.addAction(deleteConfirmAction)
            
            controller.present(deleteAlert, animated: true)
            
        }
        
        alert.addAction(editAction)
        
        alert.addAction(deleteAction)
        
        alert.addAction(cancel)
        
        // iPad specific code
        AlertWindowManager.shared.configureIpadAlert(at: controller, with: alert)
        
        controller.present(alert, animated: true)
    }

    func showShareActivity(at controller: UIViewController) {

        // Generate the screenshot
        UIGraphicsBeginImageContext(controller.view.frame.size)

        controller.view.layer.render(in: UIGraphicsGetCurrentContext()!)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        let items: [Any] = [image]

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        configureIpadAlert(at: controller, with: activityVC)

        controller.present(activityVC, animated: true)
    }

    func configureIpadAlert(at controller: UIViewController, with alert: UIViewController) {

        alert.popoverPresentationController?.sourceView = controller.view

        let xOrigin = controller.view.bounds.width / 2

        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)

        alert.popoverPresentationController?.sourceRect = popoverRect

        alert.popoverPresentationController?.permittedArrowDirections = .up
    }
}
