//
//  StarListModel.swift
//  iOSStar
//
//  Created by sum on 2017/5/11.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import RealmSwift
class BaseModel: OEZModel {
    override class func jsonKeyPostfix(_ name: String!) -> String! {
        return "";
    }
    deinit {
        
    }
}

class StarListModel: BaseModel {

  
    var depositsinfo : [StarInfoModel]?
    

    class func depositsinfoModelClass() ->AnyClass {
        return  StarInfoModel.classForCoder()
    }

}
class StartModel: Object {
    
   dynamic var accid : String = ""
   dynamic var brief : Int64 = 0
   dynamic var code : String = " "
   dynamic var gender : Int64 = 0
   dynamic var name : String = ""
   dynamic  var phone : String = ""
   dynamic var price : Int64 = 0
   dynamic var pic_url_tail = ""
   override static func primaryKey() -> String?{
        return "code"
    }
    
   static func getStartName(startCode:String,complete: CompleteBlock?){
        
        let realm = try! Realm()
        let filterStr = "code = '\(startCode)'"
        let user = realm.objects(StartModel.self).filter(filterStr).first
        if user != nil{
            complete?(user as AnyObject)
        }else{
            complete?(nil)
        }
        
        
    }
    static func getallStartName(complete: CompleteBlock?){
        
        var data = [StartModel]()
        let realm = try! Realm()
        let user = realm.objects(StartModel.self)
        if user.count != 0{
            
            for list in user{
             data.append(list)
            }
            complete?(data as AnyObject)
        }else{
            complete?(nil)
        }
        
        
    }
    
    
}

class StarInfoModel: NSObject {
    
    var faccid : String = ""
    var status : Int64 = 0
    var ownseconds : Int64 = 0
    var appoint : Int64 = 0
    var starcode : String = ""
    var starname : String = ""
    var uid : Int64 = 0
    var accid : String = ""
    var unreadCount = 0
    var work = ""
 
}
class OrderStarListInfoModel: NSObject {
    
    var star_code : String = "-"
    var star_name : String = "-"
    var star_pic_tail : String = "-"
    var star_type : Int64 = 0
    var meet_id  = 1
    var meet_name : String = "-"
    var meet_time : String = "-"
    var meet_type = 1
    var comment : String = "-"
    
    
    
}
class OrderStarListModel: NSObject {
    
    var list : [OrderStarListInfoModel]?
    
    
    class func listModelClass() ->AnyClass {
        return  OrderStarListInfoModel.classForCoder()
    }
   
    
    
}

