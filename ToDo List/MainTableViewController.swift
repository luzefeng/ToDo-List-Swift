//
//  MainTableViewController.swift
//  ToDo List
//
//  Created by lu on 15/10/5.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit
import SWTableViewCell
import SQLite
import RMDateSelectionViewController

class MainTableViewController: UITableViewController, SWTableViewCellDelegate, AddViewDelegate {
    let reuseIdentifier = "Cell"
    let mySectionArr: [String] = ["今天", "明天", "以后"]
    
    //添加提醒事件的界面
    var addView: AddView?
    //分别保存今天明天以后事件
    var todayItem = NSMutableOrderedSet()
    var tommorrowItem = NSMutableOrderedSet()
    var afterItem = NSMutableOrderedSet()
    //数据库句柄
    var db: DbRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        initDb()
        initData()
        initNotification()
        showAllNotification()
    }
    
    func setupView(){
        addBarButtonItem()
    }
    
    //初始化sqlite
    func initDb(){
        db = DbRecord()
    }
    
    //获取sqlite里面已有数据
    func initData(){
        for item in (db?.getAllItems())!{
            addItemIntoOrderSet(item as! TodoItem)
        }
        //按时间顺序进行排序
        sort(todayItem)
        sort(tommorrowItem)
        sort(afterItem)
    }
    
    //添加右上角的添加按钮
    func addBarButtonItem(){
        //        var items = [UIBarButtonItem]()
        //        let item = UIBarButtonItem(image: UIImage(named: "Set"), style: UIBarButtonItemStyle.Plain, target: self, action: "setting:")
//        let returnButtonItem = UIBarButtonItem()
//        returnButtonItem.title = "返回"
//        self.navigationItem.backBarButtonItem = returnButtonItem
        let item = UIBarButtonItem(image: UIImage(named: "list@2x.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "tapHeader:")
        //        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 20, height: 80))
        //        items.append(item)
        //        bar.setItems(items, animated: false)
        //        self.navigationController?.navigationBar.addSubview(bar)
        //        self.view.addSubview(bar)
        self.navigationItem.rightBarButtonItem = item
        self.navigationController?.navigationBar.tintColor = UIColor.mainColor()
    }
    
    //点击后出现添加界面
    func tapHeader(sender: UIButton)
    {
        if self.addView != nil{
            print("addview already exist")
            return
        }
        
        tableView.scrollEnabled = false
        self.addView = AddView(frame: self.view.bounds)
        self.addView?.delegate = self
        UIView.animateWithDuration(NSTimeInterval(1)) { () -> Void in
            
            self.view.addSubview(self.addView!)
        }
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        //        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /**************************notification*******************************/
    /*********************************************************************/
    //初始化通知动作
    func initNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showItem:", name: "AcceptPressed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nothing:", name: "IgnorePressed", object: nil)
    }
    
    func showItem(notification: NSNotification){
        print("you pressed accept")
        print(notification.userInfo)
    }
    
    func nothing(notification: NSNotification){
        print("nothing")
        print(notification.userInfo)
    }
    
    //显示所有通知，调试专用
    func showAllNotification(){
        let array = UIApplication.sharedApplication().scheduledLocalNotifications
        var count = 0
        if array != nil{
            for notification in array!{
                print("has notification: \(notification.userInfo)")
//                let userInfo = notification.userInfo
//                let index = userInfo!["index"] as! Int64
//                
//                print("index = \(index)")
                count++
            }
        }
        print("total notification = \(count)")
    }
    
    //添加本地通知
    func addNotification(item: TodoItem){
//        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        let notification = UILocalNotification()
        //超时时间
        notification.fireDate = item.time
        //setting timeZone as localTimeZone
        notification.timeZone = NSTimeZone.localTimeZone()
        //重复间隔，默认不重复
//        notification.repeatInterval = NSCalendarUnit.NSYearCalendarUnit
        //标题
        notification.alertTitle = "This is a local notification"
        //具体内容
        notification.alertBody = item.detail
        notification.alertAction = "ToDo List"
        notification.category = "ToDoNotification" //这个很重要，跟上面的动作集合（UIMutableUserNotificationCategory）的identifier一样
        //播放声音
        notification.soundName = UILocalNotificationDefaultSoundName
        //setting app's icon badge
//        notification.applicationIconBadgeNumber = 1
//        notification.repeatInterval = NSCalendarUnit.Minute
        
        var userInfo:[NSObject : AnyObject] = [NSObject : AnyObject]()
        //可保存参数
        userInfo["data"] = Int(item.index!)
        notification.userInfo = userInfo
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        print("add notification: \(item)")
//        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        showAllNotification()
    }
    
    //通过保存的index来找到对应的通知，删除
    func deleteNotification(item: TodoItem){
        let array = UIApplication.sharedApplication().scheduledLocalNotifications
        if array != nil{
            for notification in array!{
                print(notification.userInfo)
                let userInfo = notification.userInfo
                var infoItem: Int
                if let userInfoItem = userInfo?["data"]{
                    infoItem = Int(userInfoItem as! NSNumber)
                    if infoItem == Int(item.index!){
                        UIApplication.sharedApplication().cancelLocalNotification(notification)
                        print("delete notification: \(item)")
                    }
                }
                
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //get对应的set
    func getOrderSetBySection(section: Int)->NSMutableOrderedSet{
        switch section{
        case 0:
            return todayItem
        case 1:
            return tommorrowItem
        case 2:
            return afterItem
        default:
            return todayItem
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SWTableViewCell

        //右划操作
        let leftUtilityButtons = NSMutableArray()
//        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.07, green: 0.75, blue: 0.16, alpha: 1), icon: UIImage(named: "check@2x.png"))
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 191/255, green: 177/255, blue: 194/255, alpha: 1), icon: UIImage(named: "clock@2x.png"))
        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 1.0, green: 0.231, blue: 0.188, alpha: 1), icon: UIImage(named: "cross@2x.png"))
//        leftUtilityButtons.sw_addUtilityButtonWithColor(UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1), icon: UIImage(named: "list@2x.png"))
        cell.setLeftUtilityButtons(leftUtilityButtons as [AnyObject], withButtonWidth: CGFloat(40))
        cell.delegate = self
        
        //设定每个cell的title和subtitle
        let item = getOrderSetBySection(indexPath.section).objectAtIndex(indexPath.row) as! TodoItem
        cell.textLabel?.text = item.detail
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "yyyy/M/d h:m a"
        cell.detailTextLabel?.text = formatter.stringFromDate(item.time)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    //点击选择时间按钮触发操作
    func pressDateButton(date: NSDate?) {
        let style = RMActionControllerStyle.White
        
        let selectAction = RMAction(title: "选择", style: RMActionStyle.Done, andHandler: { controller in
            self.addView?.date = (controller.contentView as! UIDatePicker).date
            print((controller.contentView as! UIDatePicker).date)
        })
 
        let cancelAction = RMAction(title: "取消", style: RMActionStyle.Cancel, andHandler: { controller in
            print("Date selection was canceled")
        })
        
        let dateSelectionController = RMDateSelectionViewController(style: style, title: "Title", message: "Message", selectAction: selectAction, andCancelAction: cancelAction)

        let in15MinAction = RMAction(title: "15 分钟", style: RMActionStyle.Additional, andHandler: { controller in
//            (controller.contentView as! UIDatePicker).date = NSDate(timeIntervalSinceNow: NSTimeInterval(15*60))
            (controller.contentView as! UIDatePicker).date = NSDate(timeInterval: NSTimeInterval(15*60), sinceDate: (controller.contentView as! UIDatePicker).date)
            print("add 15 mins")
        })

        in15MinAction.dismissesActionController = false
        
        let in30MinAction = RMAction(title: "30 分钟", style: RMActionStyle.Additional, andHandler: { controller in
            (controller.contentView as! UIDatePicker).date = NSDate(timeInterval: NSTimeInterval(30*60), sinceDate: (controller.contentView as! UIDatePicker).date)
            print("add 30 mins")
        })
        in30MinAction.dismissesActionController = false
        
        let in45MinAction = RMAction(title: "45 分钟", style: RMActionStyle.Additional, andHandler: { controller in
            (controller.contentView as! UIDatePicker).date = NSDate(timeInterval: NSTimeInterval(45*60), sinceDate: (controller.contentView as! UIDatePicker).date)
            
            print("add 45 mins")
        })
        in45MinAction.dismissesActionController = false
        
        let in60MinAction = RMAction(title: "60 分钟", style: RMActionStyle.Additional, andHandler: { controller in
            (controller.contentView as! UIDatePicker).date = NSDate(timeInterval: NSTimeInterval(60*60), sinceDate: (controller.contentView as! UIDatePicker).date)
            print("add 60 mins")
        })
        in60MinAction.dismissesActionController = false
        
        let groupedAction = RMGroupedAction(style: RMActionStyle.Additional, andActions: [in15MinAction, in30MinAction, in45MinAction, in60MinAction])
        
        dateSelectionController.addAction(groupedAction)

        let nowAction = RMAction(title: "现在", style: RMActionStyle.Additional, andHandler: { controller in
            (controller.contentView as! UIDatePicker).date = NSDate()
            print("now")
        })

        nowAction.dismissesActionController = false
        
        dateSelectionController.addAction(nowAction)
        
        //You can enable or disable blur, bouncing and motion effects
        dateSelectionController.disableBouncingEffects = true
        dateSelectionController.disableMotionEffects = true
        dateSelectionController.disableBlurEffects = false
        
        //You can access the actual UIDatePicker via the datePicker property
        dateSelectionController.datePicker.datePickerMode = UIDatePickerMode.DateAndTime
        dateSelectionController.datePicker.minuteInterval = 1
        if date == nil{
            dateSelectionController.datePicker.date = NSDate()
        }else{
            dateSelectionController.datePicker.date = date!
        }
        
        self.presentViewController(dateSelectionController, animated: true, completion: nil)
    }
    
    
    
    /**************************swiptable action***************************/
    /*********************************************************************/
    //删除某个事件
    func deleteItem(indexPath: NSIndexPath){
        let orderSet = getOrderSetBySection(indexPath.section)
        let item = orderSet.objectAtIndex(indexPath.row) as! TodoItem
        //根据index删除db里的数据
        let result = db?.deleteItemByIndex(item.index!)
        if result != true{
            return
        }else{
            //删除orderset里的和notification
            orderSet.removeObjectAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            deleteNotification(item)
        }
    }
    
    //在修改了时间或者事件内容后触发跟新事件
    func updateItem(indexPath: NSIndexPath){
        if self.addView != nil{
            print("addview already exist")
            return
        }
        //去使能右上角
        self.navigationItem.rightBarButtonItem?.enabled = false
        let orderSet = getOrderSetBySection(indexPath.section)
        let item = orderSet.objectAtIndex(indexPath.row) as! TodoItem
        
        //无法滚动
        tableView.scrollEnabled = false
        self.addView = AddView(frame: self.view.bounds)
        self.addView?.item = TodoItem(detail: item.detail, time: item.time)
        self.addView?.indexPath = indexPath
        self.addView?.item?.index = item.index
        self.addView?.delegate = self
        self.view.addSubview(self.addView!)
    }
    
    
    /**************************add and update item************************/
    /*********************************************************************/
    //点击cancel按钮之后要恢复原样
    func pressCancelButton() {
        self.addView?.removeFromSuperview()
        self.addView = nil
        self.tableView.scrollEnabled = true
        self.navigationItem.rightBarButtonItem?.enabled = true
    }
    
    //点击确定
    func pressOkButton(item: TodoItem, indexPath: NSIndexPath) {
        let orderSet = getOrderSetBySection(indexPath.section)
        //恢复原样
        self.addView?.removeFromSuperview()
        self.addView = nil
        self.tableView.scrollEnabled = true
        self.navigationItem.rightBarButtonItem?.enabled = true

        //新添加事件
        if item.index == nil{
            item.index = addItemIntoSQLite(item)
            addItemIntoOrderSet(item)
            addNotification(item)
        }else{
            //更新事件
            updateItemInSQLite(item)
            updateItemInOrderSet(item, indexPath: indexPath)
            deleteNotification(item)
            addNotification(item)
        }
        
        //重新排序
        sort(orderSet)
        self.tableView.reloadData()
    }
    
    //sqlite添加操作
    func addItemIntoSQLite(item: TodoItem) -> Int64{
        return (db?.insertItem(item))!
    }
    //update
    func updateItemInSQLite(item: TodoItem){
        return (db?.updateItemByIndex(item))!
    }
    
    //add orderset
    func addItemIntoOrderSet(item: TodoItem){
        let type = getTypeOfItem(item)
        
        switch type{
        case .Today:
            self.todayItem.addObject(item)
        case .Tomorrow:
            self.tommorrowItem.addObject(item)
        case .After:
            self.afterItem.addObject(item)
        case .Before:
            break
        }
    }
    
    //update orderset
    func updateItemInOrderSet(item: TodoItem, indexPath: NSIndexPath){
        let orderSet = getOrderSetBySection(indexPath.section)
        let oldItem = orderSet.objectAtIndex(indexPath.row) as! TodoItem
        //需要判断跟新后事件的时间是否和原来的不再同一天
        if getTypeOfItem(oldItem) != getTypeOfItem(item){
            addItemIntoOrderSet(item)
            orderSet.removeObjectAtIndex(indexPath.row)
        }else{
            oldItem.detail = item.detail
            oldItem.time = item.time
        }
    }
    
    //排序
    func sort(orderSet: NSMutableOrderedSet){
        let tempArray = orderSet.sortedArrayUsingComparator({(one: AnyObject, two: AnyObject) -> NSComparisonResult in
            let interval = (one as! TodoItem).time.timeIntervalSinceDate((two as! TodoItem).time)
            if interval < NSTimeInterval(0){
                return NSComparisonResult.OrderedAscending
            }else if interval == NSTimeInterval(0){
                return NSComparisonResult.OrderedSame
            }else{
                return NSComparisonResult.OrderedDescending
            }
        })
        orderSet.removeAllObjects()
        orderSet.addObjectsFromArray(tempArray)
    }
    
    //date转为string
    func getStringFromDate(date: NSDate) -> String{
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return formatter.stringFromDate(date)
    }
    //反
    func getDateFromString(string: String) -> NSDate{
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return formatter.dateFromString(string)!
    }
    
    //判断时间为今天/明天/以后
    func getTypeOfItem(item: TodoItem) -> ItemType{
        let secondsPerDay: NSTimeInterval = 24 * 60 * 60
        let today = NSDate()
        print(getStringFromDate(today))
        print(getDateFromString(getStringFromDate(today)))
        let tomorrow: NSDate = today.dateByAddingTimeInterval(secondsPerDay)
        print(tomorrow)
        
        // 10 first characters of description is the calendar date:
        let todayString: NSString = NSString(string: getStringFromDate(today)).substringToIndex(10)
        
        let tomorrowString: NSString = NSString(string: getStringFromDate(tomorrow)).substringToIndex(10)
        let dateString: NSString = NSString(string: getStringFromDate(item.time)).substringToIndex(10)
//        print(tomorrow.description)
        if dateString.isEqualToString(todayString as String){
            return ItemType.Today
        }else if dateString.isEqualToString(tomorrowString as String){
            return ItemType.Tomorrow
        }else if dateString.compare(tomorrowString as String) == NSComparisonResult.OrderedDescending{
            return ItemType.After
        }else{
            return ItemType.Before
        }
    }
    
    
    /**************************swiptable action***************************/
    /*********************************************************************/
    //定义右划手势对应的操作
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerLeftUtilityButtonWithIndex index: Int) {
        let indexPath = self.tableView.indexPathForCell(cell)
        //        print("index = \(index), indexpath = \(indexPath)")
        
        switch index{
        case 0: updateItem(indexPath!)
        case 1:
            deleteItem(indexPath!)
        case 2:
            break
        case 3: break
        default:
            break
        }
        
    }
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        print(index)
    }
    //滑动其他行隐藏
    func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    //使能右划
    func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        return true
    }
    
    
    /**************************tableView action***************************/
    /*********************************************************************/
    //headerview
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        sectionView.backgroundColor = UIColor.clearColor()
        sectionView.tintColor = UIColor.mainColor()
//        let myButton = UIButton(type: UIButtonType.Custom)
//        myButton.imageView?.image = UIImage(named: "list@2x.png")
//        
//        myButton.frame = CGRectMake(self.view.frame.width - 40, 0, 40, 40);
//        myButton.tag = 100 + section;
//        myButton.addTarget(self, action: "tapHeader:", forControlEvents: UIControlEvents.TouchUpInside)
//
//
//        sectionView.addSubview(myButton)
        
        //设置每一行的题目
        let myLabel = UILabel(frame: CGRect(x: 15, y: 0, width: 100, height: 40))
        
        myLabel.backgroundColor = UIColor.clearColor()
        myLabel.text = mySectionArr[section]
        myLabel.textColor = UIColor.mainColor()
        //        myLabel.font = UIFont(name: <#T##String#>, size: <#T##CGFloat#>)
        sectionView.addSubview(myLabel)
        
        return sectionView;
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getOrderSetBySection(section).count
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
