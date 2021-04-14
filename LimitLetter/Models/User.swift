//
//  User.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/01/20.
//
import Foundation
import Firebase

struct User {
    
    let name:String
    let createdAt:Timestamp
    let email:String
    let profileImageUrl:String
    
    init(dic: [String:Any]){
        self.name=dic["name"] as? String ?? ""
        self.createdAt=dic["createdAt"] as? Timestamp ?? Timestamp()
        self.email=dic["email"] as? String ?? ""
        self.profileImageUrl=dic["profileImageURL"] as? String ?? ""
    }
    
}

