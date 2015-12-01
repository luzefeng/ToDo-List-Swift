//
//  TodoItem.swift
//  ToDo List
//
//  Created by lu on 15/10/17.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit

class TodoItem: NSObject {
    var detail: String
    var time: NSDate
    //索引，依次+1
    var index: Int64?
    
    
    init(detail: String, time: NSDate) {
        self.detail = detail
        self.time = time
    }
}


enum ItemType{
    case Before
    case Today
    case Tomorrow
    case After
}