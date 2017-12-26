//
//  ViewController.swift
//  CosmoLocator
//
//  Created by Ansar Khan on 2017-12-23.
//  Copyright © 2017 Ansar Khan. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import Firebase


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeDriveReadonly]
    
    @IBOutlet weak var photoPicker: UIImageView!
    @IBOutlet var photoPickerTap: UITapGestureRecognizer!
    private let service = GTLRDriveService()
    let signInButton = GIDSignInButton()
    let output = UITextView()
    var storage = FIRStorage.storage();
    var currentImage: UIImage?;
    var googleUser: GIDGoogleUser?;
   // var storageRef: FIRStorageReference? = nil;

    

 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        signInButton.center = view.center;
//        GIDSignIn.sharedInstance().signInSilently()
//               GIDSignIn.sharedInstance().clientID = ""
        GIDSignIn.sharedInstance().clientID = "315162825393-180p8sj76vebm9kd53ls5lblp3ek5ubf.apps.googleusercontent.com"
        storage = FIRStorage.storage(url:"gs://cosmolocator.appspot.com")


        
        // Add the sign-in button.
        view.addSubview(signInButton)   
       // print("This is me:" + GIDSignIn.sharedInstance().clientID)
        
        // Add a UITextView to display output.
        photoPicker.isHidden = true;
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output)
    }

    
    @IBAction func photoPickerTapped(_ sender: UITapGestureRecognizer) {

        print("Tapped")
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoPicker.image = selectedImage
        currentImage = selectedImage;
        // Dismiss the picker.
        if currentImage != nil {
            let imageData: Data?
            imageData = UIImagePNGRepresentation(currentImage!)
            if(imageData != nil){
                uploadToFirebase(data: imageData!)
            }
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}









extension ViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            photoPicker.isHidden = false;
            googleUser = user;
            self.signInButton.isHidden = true
           // self.output.isHidden = false
            //self.service.authorizer = user.authentication.fetcherAuthorizer()
            //listFiles()
        }
    }
    
    // List up to 10 files in Drive
    func listFiles() {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 10
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    func uploadToFirebase(data: Data) {
        var fileName = "";
        if(googleUser != nil){
            if(googleUser?.profile != nil){
                if(googleUser?.profile.givenName != nil){
                    fileName = (googleUser?.profile.givenName)! + " " + getTodayString();
                }
            }
        }
        if(fileName == ""){
            fileName = getTodayString();
        }
      
        let ref = FIRStorage.storage().reference().child(fileName);

        let uploadTask = ref.put(data, metadata: nil) { metadata, error in
            if let error = error {
                print("Messed up uploading the file: " + error.localizedDescription)
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()
                self.showAlert(title: "Success", message: "Uploaded " + fileName + " to server")
            }
        }
        
    }
    
    // Process the response and display output
    @objc func displayResultWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRDrive_FileList,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var text = "";
        if let files = result.files, !files.isEmpty {
            text += "Files:\n"
            for file in files {
                text += "\(file.name!) (\(file.identifier!))\n"
            }
        } else {
            text += "No files found."
        }
        output.text = text
    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
    
}

extension ViewController: GIDSignInUIDelegate {
    
}

