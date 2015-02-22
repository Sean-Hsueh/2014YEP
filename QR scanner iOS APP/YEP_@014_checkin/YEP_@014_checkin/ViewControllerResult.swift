//
//  viewControllerResult.swift
//  YEP_2014_sign_in
//
//  Created by Kokskuld on 2014/11/9.
//  Copyright (c) 2014年 Sean. All rights reserved.
//

import UIKit
import Foundation


class ViewControllerResult: UIViewController, QRCodeReaderDelegate
{
    lazy var reader: QRCodeReader = QRCodeReader(cancelButtonTitle: "Cancel")
    var data_title = [String]()
    var user_data_list = [String:[String: String]]()
    var current_IBMer_id: String = "T201533"
    
    @IBOutlet weak var labelTraveler: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelMeatEater: UILabel!
    @IBOutlet weak var labelVegeEater: UILabel!
    @IBOutlet weak var imageViewBackground: UIImageView!
    
    @IBOutlet weak var buttonScan: UIButton!
    @IBOutlet weak var buttonUploadResult: UIButton!
    @IBOutlet weak var buttonLocalSaveResult: UIButton!
    @IBOutlet weak var buttonInputID: UIButton!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //self.deleteSavedFile()

        self.recevieQRcodeData(self.current_IBMer_id)
    }
    /*
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.LandscapeLeft.rawValue
    }
    */
    func popScanningWindow(){
        reader.modalPresentationStyle = .FormSheet
        reader.delegate               = self
        
        var result: String!
        reader.completionBlock = { (result: String?) in
            println(result)
            
            if (result != nil){
                self.current_IBMer_id = result!.uppercaseString
                
                self.recevieQRcodeData(self.current_IBMer_id)
                self.reader.viewWillDisappear(true)
                
            }
        }
        presentViewController(reader, animated: true, completion: nil)
    }
    
    func updateAllCheckinIBMer(){
        for id in self.user_data_list.keys{
            if (self.user_data_list[id]!["已報到"] != "FALSE"){
                self.uploadResult(id)
            }
        }
    }
    
    func uploadTestData(){
        // Upload some test data
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        
        
        // Upload Austria
        self.user_data_list["001639"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["003459"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["006007"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["008538"]!["已報到"] = formatter.stringFromDate(date)
        self.uploadResult("001639")
        self.uploadResult("003459")
        self.uploadResult("006007")
        self.uploadResult("008538")
        
        // Upload Africa
        self.user_data_list["000315"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["002150"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["002151"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["004964"]!["已報到"] = formatter.stringFromDate(date)
        self.uploadResult("000315")
        self.uploadResult("002150")
        self.uploadResult("002151")
        self.uploadResult("004964")
        
        // Upload America
        self.user_data_list["000392"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["005030"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["005791"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["006177"]!["已報到"] = formatter.stringFromDate(date)
        self.uploadResult("000392")
        self.uploadResult("005030")
        self.uploadResult("005791")
        self.uploadResult("006177")
        
        // Upload Europe
        self.user_data_list["000459"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["000710"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["001328"]!["已報到"] = formatter.stringFromDate(date)
        self.user_data_list["005025"]!["已報到"] = formatter.stringFromDate(date)
        self.uploadResult("000459")
        self.uploadResult("000710")
        self.uploadResult("001328")
        self.uploadResult("005025")

    }
    
    func check_in() -> Bool{
        
        // Perform check in
        if (self.user_data_list.indexForKey(self.current_IBMer_id) != nil)
        {
            // Helper IDs
            if(self.current_IBMer_id == "-1"){
                self.deleteSavedFile()
                return true
            }
            if(self.current_IBMer_id == "-2"){
                self.updateAllCheckinIBMer()
                return true
            }
            
            if(self.current_IBMer_id == "-3"){
                self.uploadTestData()
                return true
            }
            
            var report_status = self.user_data_list[self.current_IBMer_id]!["已報到"]
            println("報到時間：\(report_status)")
            
            if (self.user_data_list[self.current_IBMer_id]!["已報到"] == "FALSE")
            {
                var upload_rtn:String = self.uploadResult(self.current_IBMer_id)
                
                let test:Bool = upload_rtn == "EXISTED"
                println("Upload result = '\(upload_rtn)', test = '\(test)'")
                
                if (upload_rtn == "OK"){
                    println("報到OK～")
                    self.showAlertDuplicatedCheckIn("Just arrived")
                }
                else if (upload_rtn == "Online check failed, no internet connection"){
                    println("報到OK～")
                    self.showAlertDuplicatedCheckIn("Just arrived (offline)")
                }
                else if (upload_rtn == "EXISTED"){
                    println("Duplicated online check in result")
                    self.showAlertDuplicatedCheckIn("Checked in from another side")
                }
                
                let date = NSDate()
                let formatter = NSDateFormatter()
                formatter.timeStyle = .MediumStyle
                
                self.user_data_list[self.current_IBMer_id]!["已報到"] = formatter.stringFromDate(date)
                self.writeToSavedFile(self.user_data_list[self.current_IBMer_id]!)
                return true
            }
            else {
                println("報到過囉～")
                self.showAlertDuplicatedCheckIn("Already checked in")
            }
            
        }
        
        return false
    }
    
    func uploadResult(var id_to_upload:String) -> String{
        //let url = NSURL(string:"http://127.0.0.1:16500/")
        let url = NSURL(string:"http://162.222.179.179:8083/check_in")
        let cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(URL: url!, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.HTTPMethod = "POST"
        
        // set Content-Type in HTTP header
        let boundaryConstant = "----------V2ymHFg03esomerandomstuffhbqgZCaKO6jy";
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        NSURLProtocol.setProperty(contentType, forKey: "Content-Type", inRequest: request)
        
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        
        self.user_data_list[self.current_IBMer_id]!["已報到"] = formatter.stringFromDate(date)

        // set data
        var dataString = self.JSONStringify(self.user_data_list[id_to_upload]!)
        println(dataString)
        let requestBodyData = (dataString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = requestBodyData
        
        // set content length
        //NSURLProtocol.setProperty(requestBodyData.length, forKey: "Content-Length", inRequest: request)
        
        var response: NSURLResponse? = nil
        var error: NSError? = nil
        let reply = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
        var results: NSString!
        
        if (reply != nil){
            results = NSString(data:reply!, encoding:NSUTF8StringEncoding)
            println("API Response: \(results)")
            
            if (results == "OK"){
                println("Get OK!!")
            }
        }
        else{
            results = "Online check failed, no internet connection"
            println("API Responsed nil")
        }
        
        return results
    }
    
    func recevieQRcodeData(var toPass: String){
        
        toPass = toPass.uppercaseString
        var user_data_list = self.loadIBMerData()
        
        if (user_data_list.indexForKey(toPass.uppercaseString) != nil)
        {
            println("=>\n\n")
            println(user_data_list[toPass]!)
            
            labelName.text = user_data_list[toPass]!["員工英文姓名"]!
            labelID.text = user_data_list[toPass]!["ID"]!
            var state:String = user_data_list[toPass]!["目的地"]!
            labelTraveler.text = "\(state)旅客"
            
            var vegCount:Int! = user_data_list[toPass]!["吃素人數"]!.toInt()
            var totalCount:Int! = user_data_list[toPass]!["免費人數"]!.toInt()! + user_data_list[toPass]!["付費人數"]!.toInt()!
            
            labelMeatEater.text = String(totalCount - vegCount)
            labelVegeEater.text = String(vegCount)
        }
        else
        {
            println("The requested ID \(toPass) cannot be found")
            self.showAlertDuplicatedCheckIn("Not found")
        }
    }

    func writeToSavedFile(var dataToWrite: [String:String]){
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if ((dirs) != nil) {
            let dir = dirs![0]; //documents directory
            let path = dir.stringByAppendingPathComponent("SaveFile.txt");
            
            var dataString = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
            dataString += "\n"
            
            for index in 0...(self.data_title.count-1){
                dataString += String(dataToWrite[self.data_title[index]]!)
                dataString += ","
            }
            
            //writing
            dataString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
            
            //reading
            let text2 = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
            println("text2 = \(text2)")
        }
    }
    
    func writeToSavedFile(var dataToWrite: [String]){
        let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        if ((dirs) != nil) {
            let dir = dirs![0]; //documents directory
            let path = dir.stringByAppendingPathComponent("SaveFile.txt");
            
            var dataString:String = ""
            for index in 0...(dataToWrite.count-1){
                dataString += dataToWrite[index]
                dataString += ","
            }
            
            
            //writing
            dataString.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
            
            //reading
            let text2 = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
            println("text2 = \(text2)")
        }
    }
    
    func deleteSavedFile(){
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var savedFilePath = paths.stringByAppendingPathComponent("SaveFile.txt")
        var checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(savedFilePath))
        {
            println("Found file and deleting")
            user_data_list = [String:[String: String]]()
            checkValidation.removeItemAtPath(savedFilePath, error: NSErrorPointer())
        }
    }
    
    func loadIBMerData() -> [String:[String: String]]
    {
        
        if user_data_list.count == 0
        {
            let bundle = NSBundle.mainBundle()
            var path = bundle.pathForResource("Sample", ofType: "txt")
            var raw_input = String(contentsOfFile: path!)!
            
            var lines = raw_input.componentsSeparatedByString("\r")
            self.data_title = lines[0].componentsSeparatedByString(",")
            for raw in 1...(lines.count-1) {
                
                let raw_detail = lines[raw].componentsSeparatedByString(",")
                var user_detail = [String: String]()
                for column in 0...(self.data_title.count-1){
                    user_detail[self.data_title[column]] = raw_detail[column]
                }
                
                user_data_list[raw_detail[2].uppercaseString] = user_detail
            }
            
            //let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
            //let dir = dirs![0]; //documents directory
            var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
            var savedFilePath = paths.stringByAppendingPathComponent("SaveFile.txt")
            var checkValidation = NSFileManager.defaultManager()
            
            if (!checkValidation.fileExistsAtPath(savedFilePath))
            {
                println("Saved file not exist")
                
                self.writeToSavedFile(self.data_title)
                
            }
            else{
                println("Saved file exist")

                raw_input = String(contentsOfFile: savedFilePath)!
                
                lines = raw_input.componentsSeparatedByString("\n")
                println(lines)
                for raw in 0...(lines.count-1) {
                    
                    let raw_detail = lines[raw].componentsSeparatedByString(",")
                    var user_detail = [String: String]()
                    for column in 0...(self.data_title.count-1){
                        user_detail[self.data_title[column]] = raw_detail[column]
                    }
                    
                    user_data_list[raw_detail[2].uppercaseString] = user_detail
                }
                
            }
            
    
        }
        return user_data_list
    }
    
    // -------- functions for UIViewInputID
    
    @IBAction func BeefIconTapped(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "葷食人數", message: "已為貴賓預定了\(labelMeatEater.text!)位滿漢全餐", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = sender as UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func VegeIconTapped(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "素食人數", message: "已為貴賓預定了\(labelVegeEater.text!)位頂級養生懷石料理", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = sender as UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func showActionSheetTapped(sender: AnyObject) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Welcome to 2014 YEP!!", message: "Pick an action", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add first option action
        let scanQRCodeAction: UIAlertAction = UIAlertAction(title: "Scan QR code", style: .Default) { action -> Void in
            
            println("Taking picture")
            self.popScanningWindow()
        }
        actionSheetController.addAction(scanQRCodeAction)
        
        //Create and add a second option action
        let checkInAction: UIAlertAction = UIAlertAction(title: "Check in!!", style: .Default) { action -> Void in
            //Code goes here
            let checkin_result:Bool = self.check_in()
            
        }
        actionSheetController.addAction(checkInAction)
        
        //Create and add a second option action
        let keyboardAction: UIAlertAction = UIAlertAction(title: "keyboard", style: .Default) { action -> Void in
            //Code for picking from camera roll goes here
            
            self.popKeyboard(actionSheetController)
            //self.showAlertTapped(nil)
        }
        actionSheetController.addAction(keyboardAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = sender as UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func popKeyboard(actionSheetController: UIAlertController){
        actionSheetController.dismissViewControllerAnimated(false, completion: nil)
        self.showAlertTapped(actionSheetController)
    }
    
    @IBAction func showAlertTapped(sender: AnyObject) {
        //Create the AlertController
        var inputTextField: UITextField?
        
        let actionSheetController: UIAlertController = UIAlertController(title: "Can't scan this code?", message: "key them in!!", preferredStyle: .Alert)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Do some stuff
        }
        actionSheetController.addAction(cancelAction)
        
        //Add a text field
        actionSheetController.addTextFieldWithConfigurationHandler { textField -> Void in
            //TextField configuration
            textField.textColor = UIColor.blueColor()
            
            inputTextField = textField
        }
        
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Next", style: .Default) { action -> Void in
            //Do some other stuff
            
            var inputText:String = inputTextField!.text
            
            println("Next pressed, text = \(inputText)")
            if (inputText != ""){
                self.current_IBMer_id = inputText
                self.recevieQRcodeData(inputText)
            }
            
        }
        actionSheetController.addAction(nextAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func showAlertDuplicatedCheckIn(sender: AnyObject) {
        
        var checkin_state: String = sender as NSString
        var actionSheetController: UIAlertController
        
        
        if (checkin_state == "Just arrived"){
            actionSheetController = UIAlertController(title: "線上報到成功", message: "Welcome to 2014 YEP!!", preferredStyle: .Alert)
        }
        else if (checkin_state == "Just arrived (offline)"){
            actionSheetController = UIAlertController(title: "報到成功", message: "Welcome to 2014 YEP!!", preferredStyle: .Alert)
        }
        else if (checkin_state == "Already checked in"){
            var checkin_time: String = self.user_data_list[self.current_IBMer_id]!["已報到"]!
            actionSheetController = UIAlertController(title: "報到過囉", message: "好像剛剛\(checkin_time)有看到你耶，報到兩次也不能拿兩份禮物喲", preferredStyle: .Alert)
        }
        else if (checkin_state == "Checked in from another side"){
            actionSheetController = UIAlertController(title: "報到過耶", message: "偷偷跑到別的櫃檯也只有一份禮物噢", preferredStyle: .Alert)
        }
        else if (checkin_state == "Not found"){
            actionSheetController = UIAlertController(title: "找不到耶", message: "\(current_IBMer_id)好像還沒有報名喲，請到服務台找 Gina 現場報名", preferredStyle: .Alert)
        }
        else{
            actionSheetController = UIAlertController(title: "404 ERROR", message: "Unknown check in status", preferredStyle: .Alert)
        }
        
        //Create and an option action
        let nextAction: UIAlertAction = UIAlertAction(title: "Next", style: .Default) { action -> Void in
        }
        actionSheetController.addAction(nextAction)
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    // Helper functions
    func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string
                }
            }
        }
        return ""
    }
    
    
    func reader(reader: QRCodeReader, didScanResult result: String) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func readerDidCancel(reader: QRCodeReader) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


