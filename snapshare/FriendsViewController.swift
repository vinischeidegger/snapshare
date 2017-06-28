//
//  SecondViewController.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/26/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserTableViewCellDelegate {

    var users = [User]()
    var db: DatabaseReference!
    var filteredData = [User]()
    var isSearching = false
    @IBOutlet weak var userTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.dataSource = self
        userTableView.delegate = self
        
        db = Database.database().reference()
        retrieveUsers()
    }

    func retrieveUsers() {
        let userId = Auth.auth().currentUser?.uid
        db.child("users").queryOrderedByKey().observe(.value, with: { snapshot in
            if let users = snapshot.value as? [String: [String: String]] {
                self.users.removeAll()
                for eachUser in users {
                    if (eachUser.key != userId) {
                        let user = User()
                        user.uid = eachUser.key
                        user.username = eachUser.value["name"]
                        self.users.append(user)
                        
                    }
                    self.userTableView.reloadData()
                }
            }
        })
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return filteredData.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell
        
        var user = users[indexPath.row]
        
        if isSearching {
            user = filteredData[indexPath.row]
        }
        
        cell.userNameLabel.text = user.username
        cell.selectionStyle = .none
        cell.delegate = self
        if user.follow {
            cell.followButton.setTitle("Unfollow", for: .normal)
        } else {
            cell.followButton.setTitle("Follow", for: .normal)
        }
        
        return cell
    }

    func userCellFollowButtonPressed(sender: UserTableViewCell) {
        if let indexPath = userTableView.indexPath(for: sender) {
            let user = users[indexPath.row]
            user.follow = !user.follow
            userTableView.reloadData()
            
            //Now we need to save the follow info in the database
            let userId = Auth.auth().currentUser?.uid
            
            if user.follow == true {
                //self.db.child("following").child(userId!).updateChildValues([user.uid!: user.uid!])
            } else {
                //self.db.child("following").child(userId!).child(user.uid!).removeValue()
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

