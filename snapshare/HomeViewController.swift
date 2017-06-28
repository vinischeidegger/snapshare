//
//  FirstViewController.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/26/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SDWebImage
import FBSDKLoginKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postTableView: UITableView!
    
    var dbRef : DatabaseReference!
    var currentUser : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        self.dbRef = Database.database().reference()
        self.currentUser = Auth.auth().currentUser?.uid
        
    }

    @IBAction func logoutButtonClicked(_ sender: UIBarButtonItem) {
        
        FBSDKLoginManager().logOut()
        
        UserDefaults.standard.removeObject(forKey: "userSigned")
        UserDefaults.standard.synchronize()
        
        let signUp = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
        let delegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = signUp
        delegate.rememberLogin()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        cell.userText.text = String(indexPath.row)
        cell.tapAction = { [weak self] (cell) in
        }
        return cell
    }
}

