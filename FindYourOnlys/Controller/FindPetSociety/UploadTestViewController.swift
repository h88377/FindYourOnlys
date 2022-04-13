//
//  UploadTestViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadTestViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!
    
    @IBOutlet weak var downloadImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadImage.loadImage("https://firebasestorage.googleapis.com:443/v0/b/findyouronlys.appspot.com/o/images?alt=media&token=6b3453dd-58b4-4402-b096-99009b02e2c2")
        
    }
    
    
    @IBAction func uploadToFirebase(_ sender: UIButton) {
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference()
        
        let imageRef = storageRef.child("images")
        
        guard
            let imageData = image.image?.pngData() else { return }
        
        imageRef.putData(imageData, metadata: nil) { _, error in
            
            guard
                error == nil
                    
            else {
                print(error)
                
                return
            }
            
            imageRef.downloadURL { url, error in
                guard
                    error == nil,
                    let url = url
                else {
                    print(error)
                    return
                }
                
                print(url)
            }
            
        }
        
//        firebaseFunc()
        
//        let storage = Storage.storage()
//
//        let storageRef = storage.reference()
//
//        if let uploadData = image.image!.pngData() {
//                // 這行就是 FirebaseStorage 關鍵的存取方法。
//            storageRef.putData(uploadData,
//                               metadata: nil,
//                               completion: { (data, error) in
//
//                    if error != nil {
//
//                        // 若有接收到錯誤，我們就直接印在 Console 就好，在這邊就不另外做處理。
//                        print("Error: \(error!.localizedDescription)")
//                        return
//                    }
//
//                    // 連結取得方式就是：data?.downloadURL()?.absoluteString。
////                if let uploadurl =
////                if let uploadImageUrl = data?.downloadURL()? {
////
////                        // 我們可以 print 出來看看這個連結事不是我們剛剛所上傳的照片。
////                        print("Photo Url: \(uploadImageUrl)")
////                    }
//                })
//            }
            
    }
    
    func firebaseFunc() {
        let storage = Storage.storage()
        
        let storageRef = storage.reference()
        
        // Data in memory
//        let data = Data()
        let data = image.image?.pngData()
        

        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images/rivers.jpg")

        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(data!, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          riversRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
              return
            }
          }
        }
    }
    
    

}
