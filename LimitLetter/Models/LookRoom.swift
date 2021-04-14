//
//  ChatRoom.swift
//  LimitLetter
//
//  Created by 田中　玲桐 on 2021/02/02.
//

import UIKit
import Firebase

class LookRoom {
    let name:String?
    let message:String?
    let createdAt:Timestamp
    
    
    init(dic:[String: Any]) {
        self.name=dic["name"] as? String ?? ""
   
        self.message=dic["message"] as? String ?? ""
        self.createdAt=dic["createdAt"] as? Timestamp ?? Timestamp()
    }
}
