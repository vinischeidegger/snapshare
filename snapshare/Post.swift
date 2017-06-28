//
//  Post.swift
//  snapshare
//
//  Created by Francisco San Emeterio on 6/28/17.
//  Copyright © 2017 Vinfranryia. All rights reserved.
//

class Post {
    
    var id: String?
    var createdBy: String?
    var imageUrl: String?
    var storageUUID: String?
    var subtitle: String?
    var timestamp: String?
    var userUid: String?
    var likesArray = [String]()
    var numberOfLikes: String?
    
    init(id: String?, createdBy: String?, imageUrl: String?, storageUUID: String?, subtitle: String?, timestamp: String?, userUid: String?, likesArray: [String], numberOfLikes: String?) {
        self.id = id;
        self.createdBy = createdBy;
        self.imageUrl = imageUrl;
        self.storageUUID = storageUUID;
        self.subtitle = subtitle;
        self.timestamp = timestamp;
        self.userUid = userUid;
        self.likesArray = likesArray;
        self.numberOfLikes = numberOfLikes;
    }
    
    init(id: String?, createdBy: String?, imageUrl: String?, storageUUID: String?, subtitle: String?, timestamp: String?, userUid: String?) {
        self.id = id;
        self.createdBy = createdBy;
        self.imageUrl = imageUrl;
        self.storageUUID = storageUUID;
        self.subtitle = subtitle;
        self.timestamp = timestamp;
        self.userUid = userUid;
    }
}
