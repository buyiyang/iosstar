//
//  BarrageInfo.swift
//  iOSStar
//
//  Created by sum on 2017/7/17.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class BarrageListModel: NSObject {
    var order_type: Int64 = 0         //1.转让 2.求购
    var order_num: Int64 = 0          // 数量
    var order_price: Double = 0       // 价格
    var head_url : String = ""        // 用户头像
    var user_name : String = ""       // 用户名

}
class BarrageInfo: BaseModel {
    
    var barrage_info : [BarrageListModel]!
    
    class func barrage_infoModelClass() ->AnyClass {
        return  BarrageListModel.classForCoder()
    }
    
    
}
class HeatBarrageModel: MarketBaseModel {
    var pos = 0
    var count = 0
}
