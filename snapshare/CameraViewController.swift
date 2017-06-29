//
//  CameraViewController.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/27/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate  {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var postTextView: UITextView!
    
    var imagePicker: UIImagePickerController!
    var uuid = NSUUID().uuidString
    var postDbRef : DatabaseReference!
    var postTextPlaceholder: String = "Let's make subtitles great again..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postDbRef = Database.database().reference().child("posts")
        postTextView.delegate = self
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func cameraButtonClick(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let cameraAction = UIAlertAction(title: "Use Camera", style: .default) { (action) in
                
                let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                
                if (status == .authorized) {
                    self.showPicker(type: .camera)
                }
                if (status == .restricted) {
                    self.handleRestricted()
                }
                if (status == .denied) {
                    self.handleDenied()
                }
                if (status == .notDetermined) {
                    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                        if (granted) {
                            self.showPicker(type: .camera)
                        }
                    })
                }
            }
            alertController.addAction(cameraAction)
        }
        
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)) {
            let cameraRollAction = UIAlertAction(title: "Use Camera Roll", style: .default) { (action) in
                
                let status = PHPhotoLibrary.authorizationStatus()
                
                if (status == .authorized) {
                    self.showPicker(type: .photoLibrary)
                }
                if (status == .restricted) {
                    self.handleRestricted()
                }
                if (status == .denied) {
                    self.handleDenied()
                }
                if (status == .notDetermined) {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        if (status == PHAuthorizationStatus.authorized) {
                            self.showPicker(type: .photoLibrary)
                        }
                    })
                }
            }
            alertController.addAction(cameraRollAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showPicker(type: UIImagePickerControllerSourceType) {
        self.imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: type)!
        self.imagePicker.sourceType = type
        self.imagePicker.allowsEditing = true
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    func handleRestricted() {
        let alertController = UIAlertController(title: "Media Access Denied", message: "This device is restricted from access to media in your phone", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func handleDenied() {
        let alertController = UIAlertController(title: "Media Access Denied", message: "This device is restricted from access to media in your phone. Please update your settings", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .default) { (action) in
            DispatchQueue.main.async {
                UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.image = chosenImage
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonClick(_ sender: Any) {
        self.cameraButton.isEnabled = false
        
        let pictureFolder = Storage.storage().reference().child("pics")
        
        if let photo = UIImageJPEGRepresentation(photoImageView.image!, 0.5) {
            pictureFolder.child("\(uuid).jpg").putData(photo, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    
                    if let user = Auth.auth().currentUser! as? FirebaseAuth.User {
                        let imageURL = metadata?.downloadURL()?.absoluteString
                        let uid = user.uid
                        
                        var displayName: String
                        if user.displayName != nil {
                            displayName = user.displayName!
                        } else {
                            displayName = user.email!
                        }
                        let key = self.postDbRef.childByAutoId().key
                    
                        let photoPost = ["id" : key,"imageUrl" : imageURL!, "createdBy" : displayName, "userUid" : uid, "storageUUID": self.uuid, "subtitle" : self.postTextView.text, "timestamp": ServerValue.timestamp()] as [String : Any]
                        
                        self.postDbRef.child(key).setValue(photoPost)
                        
                        self.photoImageView.image = UIImage(named: "image_placeholder.png")
                        self.photoImageView.contentMode = UIViewContentMode.scaleAspectFit
                        self.postTextView.text = self.postTextPlaceholder
                        self.navigationItem.rightBarButtonItem?.isEnabled = false
                        self.tabBarController?.selectedIndex = 0
                    }
                    
                }
            })
        }

    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == postTextPlaceholder)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = postTextPlaceholder
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
}
