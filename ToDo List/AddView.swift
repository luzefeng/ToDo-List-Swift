//
//  AddView.swift
//  ToDo List
//
//  Created by lu on 15/10/13.
//  Copyright © 2015年 lu. All rights reserved.
//

import UIKit
import SWTableViewCell
import JGProgressHUD
import RMDateSelectionViewController
import RadioButton

class AddView: UIView, MGConferenceDatePickerDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    var item: TodoItem?{
        didSet{
            self.textView?.text = item?.detail
            self.placeHolderLabel?.hidden = true
        }
    }
    var indexPath: NSIndexPath = NSIndexPath()
    var date: NSDate?
    var delegate: AddViewDelegate?
    var widthUnit: CGFloat = 0
    var heightUnit: CGFloat = 0
    //textview中的占位灰色提示信息
    lazy var placeHolderLabel: UILabel? = {
        let label = UILabel(frame: CGRect(x: 3, y: 0, width: 100, height: 30))
        
        label.enabled = false
        label.text = "请输入内容"
        label.font = UIFont(name: "Arial", size: 10.0)
        label.textColor = UIColor.lightGrayColor()
        
        return label
    }()
    //灰色背景
    lazy var shadowView: UIView? = {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = UIColor(red: 72/255, green: 76/255, blue: 76/255, alpha: 0.5)
        let gesture = UITapGestureRecognizer(target: self, action: "hideKeyBoard")
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        return view
    }()
    //添加视图
    lazy var timeView: UIView? = {
        let view = UIView(frame: CGRect(x: self.widthUnit, y: self.heightUnit*2, width: self.widthUnit*6, height: self.heightUnit*4))
        view.backgroundColor = UIColor.whiteColor()
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 30))
        label.text = "提醒我："
        label.textColor = UIColor.mainColor()
        label.font = UIFont(name: "Arial", size: 10.0)
        view.addSubview(label)
        
        return view
    }()
    //文本框视图
    lazy var textView: UITextView? = {
        let view = UITextView(frame: CGRect(x: 10, y: 30, width: self.timeView!.frame.width - 20, height: 100))
        view.font = UIFont(name: "Arial", size: 10.0)
        view.returnKeyType = UIReturnKeyType.Done
        view.textAlignment = NSTextAlignment.Left
        view.scrollEnabled = false
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        view.layer.borderColor = UIColor.grayColor().CGColor
        view.layer.borderWidth = 1
        view.delegate = self
        
        return view
    }()
    //选择时间按钮
    lazy var dateButoon: UIButton? = {
        let button = UIButton(frame: CGRect(x: self.widthUnit, y: 150, width: self.widthUnit*4, height: 30))
        button.addTarget(self, action: "chooseDate:", forControlEvents: UIControlEvents.TouchUpInside)
        button.backgroundColor = UIColor.mainColor()
        button.setTitle("请选择时间", forState: UIControlState.Normal)
        button.titleLabel?.textAlignment = NSTextAlignment.Center
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        
        return button
    }()
    //取消
    lazy var cancelButton: UIButton? = {
        let button = UIButton(frame: CGRect(x: self.widthUnit/2, y: 240, width: self.widthUnit*2, height: 30))
        button.backgroundColor = UIColor.mainColor()
        button.setTitle("取消", forState: UIControlState.Normal)
        button.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        return button
    }()
    //确定
    lazy var doneButton: UIButton? = {
        let button = UIButton(frame: CGRect(x: self.widthUnit*3.5, y: 240, width: self.widthUnit*2, height: 30))
        button.backgroundColor = UIColor.mainColor()
        button.setTitle("确定", forState: UIControlState.Normal)
        button.addTarget(self, action: "done:", forControlEvents: UIControlEvents.TouchUpInside)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 8
        
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView(frame)
    }
    
    func addRadioButton(){
        let radio1 = RadioButton(type: UIButtonType.InfoLight)
        let radio2 = RadioButton(type: UIButtonType.ContactAdd)
        let radio3 = RadioButton(type: UIButtonType.ContactAdd)
        radio1.frame = CGRect(x: self.widthUnit, y: 200, width: 60, height: 10)
        radio2.frame = CGRect(x: self.widthUnit*2.5, y: 200, width: 30, height: 10)
        radio3.frame = CGRect(x: self.widthUnit*4, y: 200, width: 30, height: 10)
//        radio1.setTitle("once", forState: UIControlState.Normal)
        radio1.groupButtons = [radio1, radio2, radio3]
        radio1.setSelected(true)
        timeView?.addSubview(radio1)
        timeView?.addSubview(radio2)
        timeView?.addSubview(radio3)
    }
    
    func setupView(frame: CGRect){
        widthUnit = frame.width/8
        heightUnit = frame.height/8
        self.addSubview(shadowView!)
        shadowView?.addSubview(timeView!)
        timeView?.addSubview(textView!)
        textView?.addSubview(placeHolderLabel!)
        timeView?.addSubview(dateButoon!)
        timeView?.addSubview(doneButton!)
        timeView?.addSubview(cancelButton!)
//        addRadioButton()
    }
    
    //点击隐藏键盘
    func hideKeyBoard(){
        print("hideKeyBoard")
        self.textView?.resignFirstResponder()
    }
    //点击Done隐藏键盘
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    //当输入内容时placeholder隐藏
    func textViewDidChange(textView: UITextView) {
        if textView.text.length == 0{
            placeHolderLabel?.hidden = false
        }else{
            placeHolderLabel?.hidden = true
        }
    }
    //cancel
    func cancel(sender: UIButton){
        delegate?.pressCancelButton()
        releaseTimeView()
    }
    //done
    func done(sender: UIButton){
        print("done")
        //输入为空或者空格给出错误提示
        if self.textView?.text.length == 0 || textView?.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).length == 0{
            print("内容不能为空")
            let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
            hud.textLabel.text = "内容不能为空"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.showInView(self, animated: true)
            hud.dismissAfterDelay(0.5, animated: true)
            
            return
        }
        //判断是否选择时间
        if self.item == nil && self.date == nil{
            print("请选择时间")
            let hud = JGProgressHUD(style: JGProgressHUDStyle.Light)
            hud.textLabel.text = "请选择时间"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.showInView(self, animated: true)
            hud.dismissAfterDelay(0.5, animated: true)
            
            return
        }
        if self.item == nil{
            self.item = TodoItem(detail: (self.textView?.text)!, time: self.date!)
        }else if self.date != nil{
            self.item?.time = self.date!
        }
//        let item = TodoItem(detail: (self.textView?.text)!, time: self.date!)
        delegate?.pressOkButton(self.item!, indexPath: indexPath)
        releaseTimeView()
    }
    //释放内容
    func releaseTimeView(){
        print("releaseTimeView")
        self.shadowView?.removeFromSuperview()
        self.shadowView = nil
        self.textView = nil
        self.item = nil
        self.date = nil
    }
    //点击选择时间按钮
    func chooseDate(sender: UIButton){
        print("dateButton")
        hideKeyBoard()
//        let datePicker = MGConferenceDatePicker(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
//        datePicker.backgroundColor = UIColor.whiteColor()
//        datePicker.delegate = self
//        if self.item != nil{
//            datePicker.setSelectedDate(self.item?.time)
//        }
//        self.addSubview(datePicker)
        delegate?.pressDateButton(self.item?.time)
        
    }
    //选择时间界面确定回调
    func conferenceDatePicker(datePicker: MGConferenceDatePicker!, saveDate date: NSDate!) {
        print(date)
        self.date = date
        datePicker.removeFromSuperview()
    }
}
