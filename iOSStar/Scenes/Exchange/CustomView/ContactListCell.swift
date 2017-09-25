//
//  ContactListCell.swift
//  iOSStar
//
//  Created by J-bb on 17/4/26.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
class GetOrderStarsVCCell : OEZTableViewCell{
 
    @IBOutlet var dodetail: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contView: UIView!
    @IBOutlet var ownsecond: UILabel!
    var cellModel: StarInfoModel = StarInfoModel()
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func haveAChat(_sender: UIButton) {
        didSelectRowAction(3, data: cellModel)
    }
    
    override func update(_ data: Any!) {
        
        guard data != nil else{return}
        let model = data as! StarInfoModel
        StartModel.getStartName(startCode: model.starcode) { (response) in
            if let star = response as? StartModel {
                self.iconImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + star.pic_url_tail))
            }
            
        }
        cellModel = model
        nameLabel.text = model.starname
       
        ownsecond.text = "\(model.ownseconds)"
        
    }
    @IBAction func dochat(_ sender: Any) {
        didSelectRowAction(5, data: cellModel)
    }
    
    @IBAction func domeet(_ sender: Any) {
        didSelectRowAction(4, data: cellModel)
    }
}
//MARK: -普通的cell
class ContactListCell: OEZTableViewCell {

    //工作
    @IBOutlet var doStarDeatil: UIButton!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet var orderTime: UILabel!
   
    var cellModel: StarInfoModel = StarInfoModel()
    override func awakeFromNib() {
        super.awakeFromNib()
        chatButton.layer.cornerRadius = 2
        chatButton.layer.masksToBounds = true
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 2
   
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func haveAChat(_sender: UIButton) {
        didSelectRowAction(3, data: cellModel)
    }
    
    override func update(_ data: Any!) {
        
        guard data != nil else{return}
        if  let model = data as? StarInfoModel{
            unreadLabel.text = "  \(model.unreadCount)  "
            unreadLabel.isHidden = model.unreadCount == 0
            StartModel.getStartName(startCode: model.starcode) { (response) in
                if let star = response as? StartModel {
                    self.iconImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + star.pic_url_tail))
                }
                
            }
            var title = ""
            var color = ""
            if model.appoint == 0 {
                color = AppConst.Color.main
                title = "没有约见"
            } else if model.appoint == 1{
                color = AppConst.Color.main
                
                title = "待确认"
            }
            else if model.appoint == 2{
                color = "CCCCCC"
                title = "已拒绝"
            }
            else if model.appoint == 3{
                color = AppConst.Color.main
                title = "已完成"
            }
            else {
                color = AppConst.Color.main
                title = "已同意"
            }
            chatButton.setTitle(title, for: .normal)
            chatButton.backgroundColor  = UIColor.init(hexString: color)
            chatButton.backgroundColor = UIColor.init(hexString: AppConst.Color.orange)
            cellModel = model
            if (nameLabel != nil){
                nameLabel.text = model.starname
                jobLabel.text =  model.work
                chatButton.setTitle("聊一聊", for: .normal)
                
            }
            
        }
        else{
            if  let model = data as? OrderStarListInfoModel{
                var title = ""
                var color = ""
                if model.meet_type == 4 {
                    color = AppConst.Color.orange
                    title = "已同意"
                } else if model.meet_type == 1{
                     color = AppConst.Color.orange
                     title = "已预订"
                }
                else if model.meet_type == 2{
                    color = "CCCCCC"
                    title = "已拒绝"
                }
                else if model.meet_type == 3{
                     color = "CCCCCC"
                    title = "已完成"
                }
                else {
                     color = "CCCCCC"
                    title = "已同意"
                }
                chatButton.setTitle(title, for: .normal)
                chatButton.backgroundColor = UIColor.init(hexString: color)
                jobLabel.text =  model.star_name
                orderTime.text  = model.meet_time
                self.iconImageView.kf.setImage(with: URL(string:ShareDataModel.share().qiniuHeader + model.star_pic_tail))
                orderTime.text = model.meet_time
            }
        }
    }
 
}
