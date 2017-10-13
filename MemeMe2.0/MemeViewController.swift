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

class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
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
    
    var activeTextField: UITextField!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    
    @IBOutlet weak var topBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        // Do any additional setup after loading the view, typically from a nib.
        configure(topTextField, defaultText: "TOP")
        configure(bottomTextField, defaultText: "BOTTOM")
        //initially set the share button to disabled state
        shareButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if it is a simulator, camera button should be disabled else enabled
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
         subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
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
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        } else{
            self.view.frame.origin.y = 0
        }
    }
    
    //keyboard hide function
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    //function: setup the various attributes for given textfield
    func configure(_ textField: UITextField, defaultText: String){
        //setting up delegate for textfield
        textField.delegate = self
        //setting up default text for textfield's text
        textField.text! = defaultText
        //setting up default text attributes for textfield
        textField.defaultTextAttributes = memeTextAttributes
        //alignment
        textField.textAlignment = .center
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
        activeTextField = textField
        textField.text! = ""
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
    
    func setToolbar(_ toolBar: UIToolbar, bool: Bool){
        toolBar.isHidden = bool
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        setToolbar(topBar, bool: true)
        setToolbar(bottomBar, bool: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        setToolbar(topBar, bool: false)
        setToolbar(bottomBar, bool: false)
        
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

    //function: depending upon UIBarButtonItem, imagepicker source will be selected
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        if(sender.title == "Album"){
            imagePicker.sourceType = .photoLibrary
        } else {
            imagePicker.sourceType = .camera
        }
        imagePicker.delegate = self
        present(imagePicker, animated: true , completion: nil)
        shareButton.isEnabled = true
    }
    
    @IBAction func onCancel(_ sender: Any) {
    }
    
}

