//
//  ViewController.swift
//  MemeMe2.0
//
//  Created by Vaibhav Sahu on 9/25/17.
//  Copyright © 2017 Vaibhav Sahu. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    //Meme text attributes
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    
    @IBOutlet weak var topBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        //initial text of textfields
        topTextField.text! = "TOP"
        bottomTextField.text! = "BOTTOM"
        
        //setting defualt attributes for textfields
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        //initially set the share button to disabled state
        shareButton.isEnabled = false
        subscribeToKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if it is a simulator, camera button should be disabled else enabled
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
  
    //function: add observers to keyboard events
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillShow, object: nil)

    }
    //function: removes added observers to keyboard
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    //keyboard show function
    @objc func keyboardWillShow(_ notification:NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        //self.view.frame.origin.y -= getKeyboardHeight(notification as Notification)
    }
    
    //keyboard hide function
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    //this function would return the keyboard height; this function would be used keyboardShow/Hide functions
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //keyboard begin editing delegate method
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //clear the text as soon as users begin editing
        textField.text! = ""
       // bottomTextField.text! = ""
    }
    
    //keyboard return key delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.view.frame.origin.y = 0
        return true
    }
    //user selects the image picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func save() {
        // Create the meme
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        topBar.isHidden = true
        bottomBar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        topBar.isHidden = false
        bottomBar.isHidden = false
        
        return memedImage
    }
    
    //function: Share action method
    @IBAction func shareActivityAction(_ sender: Any) {
        //generate a memed image
        let memedImage: UIImage = generateMemedImage()
        let memedImageToShare = [memedImage]
        
        let activityViewController = UIActivityViewController(activityItems: memedImageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.completionWithItemsHandler = { (activity, success, items, error) in
            if(success && error == nil){
                self.save()
                self.dismiss(animated:true, completion: nil);
            }else if (error != nil){
                //log the error
            }
        };
        present(activityViewController, animated: true, completion: nil)
    }
    
    //user cancels the image picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //function: select source as camera to capture pics/memes
    @IBAction func pickImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true , completion: nil)
        _ = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    //function: select source as photo album for memes
    @IBAction func pickImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true , completion: nil)
        shareButton.isEnabled = true
    }
    
    @IBAction func onCancel(_ sender: Any) {
    }
    
}

