//
//  ProfileViewController.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/7/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var newFullName: UITextField!
    
    let defaultAvatarImage = #imageLiteral(resourceName: "blankAvatar")
    var avatar: String = ""
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        user.requestType = .getUserInfo
        
        WebServices.shared.getObject(user, completion: { (object, error) in
            if let object = object {
                self.user = object
                self.email.text = self.user.email
                self.fullName.text = self.user.fullName
                self.newFullName.text = self.user.fullName
                print(self.user.avatarBase64!)
                
                self.imageView.image = self.convertBase64ToImage(base64String: self.user.avatarBase64)
                print(self.user.avatarBase64!)
            }
        })
    }
    
    func convertImageToBase64(image: UIImage?) -> String {
        
        if let image = image, let imageData = UIImagePNGRepresentation(image){
            let base64String = imageData.base64EncodedString()

            return base64String
        }
        return ""
    }

    func convertBase64ToImage(base64String: String?) -> UIImage? {
        
        if let base64String = base64String, let photoData = NSData(base64Encoded: base64String, options: .ignoreUnknownCharacters) {
            return UIImage(data: photoData as Data)
        }
        
        return defaultAvatarImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showPicker(_ type: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = type
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func choosePhoto(_ sender: Any) {
        let alert = UIAlertController(title: "Picture", message: "Choose a picture type", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in self.showPicker(.camera) }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in self.showPicker(.photoLibrary) }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let newFullName = newFullName.text, newFullName != "" else {
            let alert = Utils.createAlert("Login Error", message: "Please provide a Full Name", dismissButtonTitle: "Dismiss")
            present(alert, animated: true, completion: nil)
            return
        }
    
        let user = User(avatarBase64: convertImageToBase64(image: imageView.image), fullName: newFullName)
        
        MBProgressHUD.showAdded(to: view, animated: true)
        WebServices.shared.postObject(user) { (success, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if (success != nil) {
                self.dismiss(animated: true, completion: nil)
            } else if let error = error {
                self.present(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                self.present(Utils.createAlert(message: Constants.JSON.unknownError), animated: true, completion: nil)
            }
        }
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) //close the image picker when the user clicks cancel
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil) //still want to close the picker even when picking an image
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage { //if we actually get an image back, do this
            let maxSize: CGFloat = 100
            let scale = maxSize / image.size.width
            let newHeight = image.size.height * scale
            
            //resizing our image and redrawing it within our image context, which is sized to maxSize for width and newHeight as height
            UIGraphicsBeginImageContext(CGSize(width: maxSize, height: newHeight))
            image.draw(in: CGRect(x: 0, y: 0, width: maxSize, height: newHeight))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext() //setting our newly sized image to a constant called resizedImage
            UIGraphicsEndImageContext()
        
            imageView.image = resizedImage
        }
    }
}
