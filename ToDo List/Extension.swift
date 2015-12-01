//
//  Extension.swift
//  ToDo List
//
//  Created by lu on 15/12/1.
//  Copyright © 2015年 lu. All rights reserved.
//

import Foundation

extension UIColor{
    class func mainColor() ->UIColor{
        return UIColor(red: 101/255, green: 191/255, blue: 234/255, alpha: 1)
    }
}

extension String {
    
    // readonly computed property
    var length: Int {
        return self.characters.count
    }
}
