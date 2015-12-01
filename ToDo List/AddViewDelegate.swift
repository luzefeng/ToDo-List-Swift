//
//  AddViewDelegate.swift
//  ToDo List
//
//  Created by lu on 15/10/17.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit

protocol AddViewDelegate: NSObjectProtocol {
    func pressCancelButton()
    func pressOkButton(item: TodoItem, indexPath: NSIndexPath)
    func pressDateButton(date: NSDate?)
}
