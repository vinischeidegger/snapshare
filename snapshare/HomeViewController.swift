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
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        self.dbRef = Database.database().reference()
        self.currentUser = Auth.auth().currentUser?.uid
        
        getPostsFromServer()
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post : Post
        post = posts[indexPath.row]
        
        let cell = postTableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostTableViewCell
        
        cell.postImage.sd_setImage(with: URL(string: post.imageUrl!))
        cell.userText.text = post.createdBy
        cell.tapAction = { [weak self] (cell) in
        }
        return cell
    }
    
    func getPostsFromServer() {
        if let userUid = Auth.auth().currentUser?.uid {
            
            self.posts.removeAll()
            
            self.dbRef.child("follows").queryOrderedByKey().queryEqual(toValue: userUid).observe(.value, with: { snapshot in
                print(snapshot)
                for case let childSnapshot as DataSnapshot in snapshot.children {
                    print("Child: ")
                    print(childSnapshot)
                    if childSnapshot.key == userUid {
                        print("Child Value: ")
                        print(childSnapshot.value)
                        var followedUsers = childSnapshot.value as? [String: [String: String]]
                        for (_, followedUser) in followedUsers! {
                            if let follId = followedUser["uid"] {
                                self.dbRef?.child("posts").queryOrdered(byChild: "userUid").queryEqual(toValue: follId).observe(.value, with: { (postSnapshot) in
                                    print(postSnapshot)
                                    
                                    if postSnapshot.childrenCount > 0 {
                                        
                                        for posts in postSnapshot.children.allObjects as! [DataSnapshot] {
                                            let postObject = posts.value as! [String : AnyObject]
                                            let post = self.createPost(postObject: postObject)
                                            self.posts.append(post)
                                            //self.posts.reverse()
                                        }
                                    }
                                    self.postTableView.reloadData()
                                    
                                    
                                })
                            }
                        }
                    }
                }
                
                
                
            })
            self.posts.sort(by: postOrder)
        }
       // self.dbRef?.child("posts").queryOrdered(byChild: "timestamp").observe(.value, with: { (snapshot) in
         //   if snapshot.childrenCount > 0 {
           //     self.posts.removeAll()
             //   for posts in snapshot.children.allObjects as! [DataSnapshot] {
               //     let postObject = posts.value as! [String : AnyObject]
                 //   let post = self.createPost(postObject: postObject)
                   // self.posts.append(post)
                    //self.posts.reverse()
    //            }
      //      }
        //    self.postTableView.reloadData()
       // })
        
    }
    
    
    func postOrder(value1: Post, value2: Post) -> Bool {
        return value1.timestamp! < value2.timestamp!;
    }
    
    func createPost(postObject: [String: AnyObject]) -> Post {
        let id = postObject["id"]
        let createdBy = postObject["createdBy"]
        let imageUrl = postObject["imageUrl"]
        let storageUUID = postObject["storageUUID"]
        let subtitle = postObject["subtitle"]
        let timestamp = postObject["timestamp"]
        let userUid = postObject["userUid"]
        return Post(id: id as? String, createdBy: createdBy as? String, imageUrl: imageUrl as? String, storageUUID: storageUUID as? String, subtitle: subtitle as? String, timestamp: timestamp as? String, userUid: userUid as? String)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
}

