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
        db.child("users").queryOrderedByKey().observe(.value, with: { snapshot in
            if let dbUsers = snapshot.value as? [String: [String: String]],
                let userId = Auth.auth().currentUser?.uid {
                
                print("Logged user "+userId)

                self.db.child("follows").queryOrderedByKey().queryEqual(toValue: userId).observe(.value, with: { snapshot in
                    
                    self.users.removeAll()
                    for eachUser in dbUsers {
                        if (eachUser.key != userId) {
                            print("Listed user "+eachUser.key)
                            let user = User()
                            user.uid = eachUser.key
                            user.username = eachUser.value["name"]
                            
                            for case let childSnapshot as DataSnapshot in snapshot.children {
                                print("Child: ")
                                print(childSnapshot)
                                if childSnapshot.key == userId {
                                    print("Child Value: ")
                                    print(childSnapshot.value)
                                    if let following = childSnapshot.value as? [String: [String: String]]{
                                        print(following)
                                        if  (following[eachUser.key] != nil) {
                                            user.follow = true
                                        }
                                    }
                                }
                            }
                            self.users.append(user)
                        }
                    }
                    self.userTableView.reloadData()
                })
            }
        })
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell
        
        var user = users[indexPath.row]
        
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
            
            //Now we need to save the follow info in the database
            if let userId = Auth.auth().currentUser?.uid,
               let followedUser = user.uid {
            
                if user.follow == true {
                    let followItem = ["uid": user.uid!]
                
                        let childUpdates = ["/follows/\(userId)/\(followedUser)": followItem,
                                    "/followedBy/\(followedUser)/\(userId)/": ["uid": userId]] as [String : Any]
                        self.db.updateChildValues(childUpdates)
                
                
                    //self.db.child("follows").ref(userId!).set(user.uid!)
                } else {
                    self.db.child("follows").child(userId).child(followedUser).removeValue()
                    self.db.child("followedBy").child(followedUser).child(userId).removeValue()
                    
                }
            }
            userTableView.reloadData()
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

