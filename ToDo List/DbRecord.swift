//
//  DbRecord.swift
//  ToDo List
//  数据库操作
//  Created by lu on 15/10/17.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit
import SQLite

class DbRecord: NSObject {
    let id = Expression<Int64>("id")
    let detail = Expression<String>("detail")
    let time = Expression<NSDate>("time")
    let items = Table("items")
    var db: Connection?
    
    override init() {
        super.init()
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        do{
            db = try Connection("\(path)/db.sqlite3")
        }catch{
            print("init db failed")
        }
        
        do{
            try db!.run(items.create(ifNotExists: true) { t in     // CREATE TABLE "users" (
                t.column(id, primaryKey: true) //     "id" INTEGER PRIMARY KEY NOT NULL,
                t.column(detail)  //     "email" TEXT UNIQUE NOT NULL,
                t.column(time)                 //     "name" TEXT
                })
        }catch{
            print("init table failed")
        }
    }
    
    func getAllItems()-> NSMutableArray{
        let array = NSMutableArray()
        var temp: TodoItem?
        for item in db!.prepare(items){
            temp = TodoItem(detail: item[detail], time: item[time])
            temp!.index = item[id]
            array.addObject(temp!)
        }
        
        return array
    }
    
    func updateItemByIndex(item: TodoItem){
        let oldItem = items.filter(id == item.index!)
        do{
            try db?.run(oldItem.update(detail <- item.detail, time <- item.time))
        }catch{
            print("update item failed")
        }
    }
    
    func insertItem(item: TodoItem) -> Int64{
        var rowid: Int64 = -1
        let insert = items.insert(detail <- item.detail, time <- item.time)
        do{
            rowid = try db!.run(insert)
        }catch{
            print("insert failed")
        }
        
        return rowid
    }
    
    func deleteItemByIndex(index: Int64) -> Bool{
        let item = items.filter(id == index)
        do{
            try db!.run(item.delete())
        }catch{
            print("delete item failed")
            return false
        }
        
        return true
    }
}





