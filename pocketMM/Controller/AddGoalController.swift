//
//  AddGoalController.swift
//  pocketMM
//
//  Created by Ly Cao on 4/26/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class AddGoalController: UIViewController {
    @IBOutlet weak var uploadTextView: UITextView!
    var imageUrl : String?
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var finishCreatingButton: UIButton!
    var firebaseManager = FirebaseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "💰Add Goals"
        self.finishCreatingButton.layer.cornerRadius = 15
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleUpload)))
        firebaseManager.userDelegate = self
    }
    
    @IBAction func createGoalClicked(_ sender: UIButton) {
        let name = nameTextField.text
        let amountStr = amountTextField.text
        //String(data: image, encoding: .utf8)
        
        if let image = imageUrl,  let amount = amountStr {
//            print(String(data: image, encoding: .utf8), image.base64EncodedString () )
            //let imageData = Data (base64Encoded: imageString)!
//            let image = NSImage (data: imageData)!
            
            if let email = Auth.auth().currentUser?.email {
                let docData : [String: Any] = [
                        CONST.FSTORE.goal_name : name,
                        CONST.FSTORE.goal_amount : Double(amount),
                        CONST.FSTORE.goal_image : image
                    ]
                db.collection(CONST.FSTORE.usersCollection).document(email).updateData([
                    CONST.FSTORE.goals : FieldValue.arrayUnion([docData])
                    ])
                firebaseManager.getUser()
//                    uploadTextView.isHidden = false
//                    uploadTextView.text = "Successfully uploaded goal"
                let alert = UIAlertController(title: "Uploaded", message: "Successfully uploaded goal", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
                
            }
        else{
            let alert = UIAlertController(title: "Uploading", message: "Something's gone wrong. Please try again!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            
        }
            
        
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
//    @IBAction func handlePanUpload(_ sender: UIPanGestureRecognizer) {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.allowsEditing = true
//        picker.sourceType = .photoLibrary;
////        uploadTextView.isHidden = false
////        uploadTextView.text = "tapped"
//        print("handling here\n ")
//        present(picker, animated: true, completion: nil)
//    }
}

extension AddGoalController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @objc func handleUpload(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary;
//        uploadTextView.isHidden = false
//               uploadTextView.text = "tapped"
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
            uploadImageToFirebase(image: selectedImage)
           DispatchQueue.main.async() {
                self.uploadImageView.image = selectedImage
                print("selected image gesture")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageToFirebase(image: UIImage){
       // Create a root reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Data in memory

        let image_name = NSUUID().uuidString
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("images/\(image_name).png")

        // Upload the file to the path "images/rivers.jpg"
        if let data = image.pngData(){
            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
              guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                self.uploadTextView.isHidden = false
                self.uploadTextView.text = error!.localizedDescription
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
                self.imageUrl = downloadURL.absoluteString
//           db.collection(CONST.FSTORE.usersCollection).document("user_good@nyu.com").updateData([
//                    CONST.FSTORE.goals : FieldValue.arrayUnion([imageName])
//                ])
                print(downloadURL, size)
              }
            }
            uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                  / Double(snapshot.progress!.totalUnitCount)
                  print("progress: ", percentComplete)
            }

          uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
              print("uploaded successfully")
          }
        }

    }
}

extension AddGoalController : FirebaseUserDelegate{
    func didFinishGettingUser(user: User) {
        print("updated user after saving new goal")
    }
    
    func didFailToGetUser() {
        //
    }
    
    
}
