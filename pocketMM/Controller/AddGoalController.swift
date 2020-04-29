//
//  AddGoalController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase

class AddGoalController: UIViewController {
    @IBOutlet weak var uploadTextView: UITextView!
    
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var uploadImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Add Goals"
        uploadImageView.isUserInteractionEnabled = true
//        uploadImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleUpload)))
    }
    
    @IBAction func createGoalClicked(_ sender: UIButton) {
        let name = nameTextField.text
        let amount = amountTextField.text
        if let image = uploadImageView.image!.pngData(){
            let docData = [
                CONST.FSTORE.goal_name : name,
                CONST.FSTORE.goal_amount : amount,
                CONST.FSTORE.goal_image : String(data: image, encoding: .utf8)
            ]
        db.collection(CONST.FSTORE.usersCollection).document("user_good@nyu.com").updateData([
            CONST.FSTORE.goals : FieldValue.arrayUnion([docData])
            ])
        }
        
    }
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    @IBAction func handlePanUpload(_ sender: UIPanGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary;
//        uploadTextView.isHidden = false
//        uploadTextView.text = "tapped"
        print("handling here\n ")
        present(picker, animated: true, completion: nil)
    }
}

extension AddGoalController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func handleUpload(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary;
//        uploadTextView.isHidden = false
        print("handling here\n ")
        present(picker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true){
//            print("cancelled gesture")
//        }
        print("cancelled gesture")
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("in picker controller")
         var selectedImageFromPicker : UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
            print("got edited image")
        }
        else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
            print("got original image")
        }
        if let selectedImage = selectedImageFromPicker{
//            self.uploadImageView.image = selectedImage
//            print("selected image gesture")
           DispatchQueue.main.async() {
                self.uploadImageView.image = selectedImage
                print("selected image gesture")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageToFirebase(image: UIImage){
       // Create a root reference
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        // Data in memory
//
//        let imageName = NSUUID().uuidString
//        // Create a reference to the file you want to upload
//        let riversRef = storageRef.child("images/\(imageName).png")
//
//        // Upload the file to the path "images/rivers.jpg"
//        if let data = image.pngData(){
//            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
//              guard let metadata = metadata else {
//                // Uh-oh, an error occurred!
//                self.uploadTextView.isHidden = false
//                self.uploadTextView.text = error!.localizedDescription
//                return
//              }
//
//              // Metadata contains file metadata such as size, content-type.
//              let size = metadata.size
//              // You can also access to download URL after upload.
//              riversRef.downloadURL { (url, error) in
//                guard let downloadURL = url else {
//                  // Uh-oh, an error occurred!
//                  return
//                }
//                db.collection(CONST.FSTORE.usersCollection).document("user_good@nyu.com").updateData([
//                    CONST.FSTORE.goals : FieldValue.arrayUnion([imageName])
//                ])
//                print(downloadURL, size)
//              }
//            }
//            uploadTask.observe(.progress) { snapshot in
//            // Upload reported progress
//                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
//                  / Double(snapshot.progress!.totalUnitCount)
//                  print("progress: ", percentComplete)
//            }
//
//          uploadTask.observe(.success) { snapshot in
//            // Upload completed successfully
//              print("uploaded successfully")
//          }
//        }
            
    }
}
