//
//  LoginViewController.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/26/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var facebookLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func alertError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func facebookLoginClicked(_ sender: UIButton) {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if (error != nil || (result?.isCancelled)!) {
                self.alertError(error: error!)
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: (result?.token.tokenString)!)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if (error != nil) {
                        self.alertError(error: error!)
                    }
                    
                    UserDefaults.standard.set(user!.uid, forKey: "userSigned")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                }
            }
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                let ref : DatabaseReference = Database.database().reference()
                let uid = user?.uid as String!
                let photoURL : String = (user?.photoURL?.absoluteString)!
                ref.child("users").child(uid!).setValue(["name": user?.displayName!, "photoURL": photoURL])
                ref.child("followedBy").child(uid!).setValue([uid! : uid!])
                ref.child("follows").child(uid!).setValue([uid! : uid!])
            }
        }
    }

    @IBAction func loginButtonClicked(_ sender: UIButton) {
        if usernameText.text != "" && passwordText.text != "" {
            Auth.auth().signIn(withEmail: usernameText.text!, password: passwordText.text!, completion: { (user, error) in
                if error != nil {
                    self.alertError(error: error!)
                } else {
                    
                    UserDefaults.standard.set(user!.uid, forKey: "userSigned")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                }
            })
        }
    }
    @IBAction func signinButtonClicked(_ sender: UIButton) {
        if usernameText.text != "" && passwordText.text != "" {
            Auth.auth().createUser(withEmail: usernameText.text!, password: passwordText.text!, completion: { (user, error) in
                if error != nil {
                    self.alertError(error: error!)

                } else {
                    
                    UserDefaults.standard.set(user!.uid, forKey: "userSigned")
                    UserDefaults.standard.synchronize()
                    
                    let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.rememberLogin()
                }
            })

    }
  }
}
