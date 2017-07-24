//
//  UserVC.swift
//  iOSStar
//
//  Created by sum on 2017/4/21.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class TitleCell: UITableViewCell {
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet var version: UILabel!
    
}

class UserVC: BaseCustomTableViewController ,NIMSystemNotificationManagerDelegate,NIMConversationManagerDelegate {

    var sessionUnreadCount : Int = 0
    // 资产总额
    var  account : UILabel?
    // 昵称
    var  nickNameLabel : UILabel?
    // icon
    var iconImageView : UIImageView?
    // 已购明星数量
    var buyStarCountLabel : UILabel?
    
    // 名字数组
    var titltArry = [""]
    //messagebtn
    @IBOutlet var message: UIButton!
    var responseData: UserInfoModel?
   
    override func viewDidLoad() {
        super.viewDidLoad()
//        titltArry = ["我的钱包","我约的明星","客服中心","常见问题","通用设置"]
        titltArry = ["我的钱包","我预约的明星","客服中心","通用设置"]
        self.tableView.reloadData()
     
        LoginYunxin()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginSuccess(_:)), name: Notification.Name(rawValue:AppConst.loginSuccess), object: nil)
        NIMSDK.shared().systemNotificationManager.add(self)
        NIMSDK.shared().conversationManager.add(self)
        self.sessionUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginSuccessNotice), name: Notification.Name(rawValue:AppConst.loginSuccessNotice), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        LoginSuccessNotice()
    }
    
    func LoginSuccessNotice() {
        
        NIMSDK.shared().systemNotificationManager.add(self)
        NIMSDK.shared().conversationManager.add(self)
        self.sessionUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        AppAPIHelper.user().requestBuyStarCount(complete: { (result) in
            
            if let model = result {
                let objectModle = model as! [String : Int]
                if objectModle["amount"] != 0{
                    self.buyStarCountLabel?.text = String.init(format:"%d",objectModle["amount"]!)
                } else {
                    self.buyStarCountLabel?.text = "0"
                }
            }
            
        }) { (error) in
            
        }
        updateUserInfo()
    }
    
    func updateUserInfo() {
       getUserInfo { (result) in
            if let response = result{

                let model =   response as! UserInfoModel
                
                self.responseData = model
                self.account?.text =  String.init(format: "%.2f", model.balance)
                if model.nick_name == "" {
                    let nameUid = StarUserModel.getCurrentUser()?.userinfo?.id
                    let stringUid = String.init(format: "%d", nameUid!)
                    self.nickNameLabel?.text = "星悦用户" + stringUid
                } else  {
                    self.nickNameLabel?.text = model.nick_name
                }
                
                self.iconImageView?.kf.setImage(with: URL(string: model.head_url), placeholder: UIImage(named:"avatar_team"), options: nil, progressBlock: nil, completionHandler: nil)
                self.tableView.reloadData()
                
            }
        }
    }
        

    // MARK: Table view data source
     override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? 1 : (section == 1 ? 4 : (section == 2 ? 1 : (section == 3 ? 1 : 3 ) ))
    }
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 2 ? 20 : (section == 3 ? 20 : 0.001)
      
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return  0.01
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 260: 44
    }
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        if indexPath.section == 0{
            account = cell.balance
            nickNameLabel = cell.nickNameLabel
            iconImageView = cell.iconImageView
            buyStarCountLabel = cell.buyStarLabel
            message = cell.message
//            self.message.setImage(UIImage.imageWith(AppConst.iconFontName.showIcon.rawValue, fontSize: CGSize.init(width: 22, height: 17), fontColor: UIColor.init(rgbHex: AppConst.ColorKey.linkColor.rawValue)), for: .normal)
           return cell
        }else if indexPath.section == 2{
            
          let cell  = tableView.dequeueReusableCell(withIdentifier: "recommandCell")
            
            return cell!
        }else if indexPath.section == 3{
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "versionCode") as! TitleCell
            
            cell.contentView.backgroundColor = UIColor.clear
             cell.version.text = "版本号" + " " + (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
            return cell
        }
        else{
            let cell  = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TitleCell
            cell.titleLb.text = titltArry[indexPath.row]
            return cell
        }
      

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            //进入个人中心
            if indexPath.row == 0{
              let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "UserInfoVC")
              // (UserInfoVC as! vc).us = self.responseData
              let userInfoVc = vc as! UserInfoVC
              userInfoVc.userInfoData = self.responseData
              self.navigationController?.pushViewController(userInfoVc, animated: true)
            }
            
        }
        if indexPath.section == 1{
        
            //GetOrderStarsVC 我的钱包
            if indexPath.row == 0{
                
                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "WealthVC")
                self.navigationController?.pushViewController(vc, animated: true)
            }
            //GetOrderStarsVC 预约明星列表
            if indexPath.row == 1{
                
                toReservationStar()

            }
            //CustomerServiceVC
            if indexPath.row == 2{
                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "CustomerServiceVC")
                self.navigationController?.pushViewController(vc, animated: true)
            }
            //CustomerServiceVC 客服中心
//            if indexPath.row == 3{
//                let vc = BaseWebVC()
//                vc.loadRequest = "http://www.baidu.com"
//                vc.navtitle = "常见问题"
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
            if indexPath.row == 3 {
                let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "SettingVC")
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        if indexPath.section == 2{
        
            showAlertView()
        }
        
    }
    
    // MARK: -我预约的明星
    func toReservationStar() {
        self.getUserRealmInfo { (result) in
            if let model = result{
                let object =  model as! [String : AnyObject]
                let alertVc = AlertViewController()
                if object["realname"] as! String == ""{
                    alertVc.showAlertVc(imageName: "tangchuang_tongzhi",
                                        titleLabelText: "您还没有身份验证",
                                        subTitleText: "您需要进行身份验证,\n之后才可以进行明星时间交易",
                                        completeButtonTitle: "开 始 验 证") {[weak alertVc] (completeButton) in
                                            alertVc?.dismissAlertVc()
                                            
                                            let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "VaildNameVC")
                                            self.navigationController?.pushViewController(vc, animated: true )
                                            return
                    }
                } else {
                    let vc = UIStoryboard.init(name: "User", bundle: nil).instantiateViewController(withIdentifier: "GetOrderStarsVC")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }

    //MARK: 输入邀请码
    func showAlertView(){
    
        let alertview : UIAlertController = UIAlertController.init(title: "请输入邀请码", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alertview.addTextField { (textField: UITextField!) in
                    textField.placeholder  = "请输入邀请码"
                    textField.keyboardType = .numberPad
                }
                let alertViewAction: UIAlertAction = UIAlertAction.init(title: "确定", style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
        
                    let string  = alertview.textFields?[0].text
        
                    if isTelNumber(num: string!){
        
                    }
                })
                let alertViewCancelAction: UIAlertAction = UIAlertAction.init(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
                alertview.addAction(alertViewAction)
                alertview.addAction(alertViewCancelAction)
                self.present(alertview, animated:true , completion: nil)
    }
   
    func  tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vi : UIView = UIView.init()
        vi.backgroundColor = UIColor.clear
        
        return vi
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let vi : UIView = UIView.init()

        vi.backgroundColor = UIColor.clear
       return vi
    }
   
    @IBAction func pushMessage(_ sender: Any) {
   
        let storyboard = UIStoryboard.init(name: "Exchange", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ExchangeViewController")
        self.navigationController?.pushViewController(controller, animated: true)
    }
   
}
extension UserVC{
    func LoginSuccess(_ LoginSuccess : NSNotification){
        
        NIMSDK.shared().systemNotificationManager.add(self)
        NIMSDK.shared().conversationManager.add(self)
        self.sessionUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
     
        print("未读消息条数====\(self.sessionUnreadCount)")
        self.refreshSessionBadge()
    }
    func didAdd(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        
        //       self.tabBar.showshowBadgeOnItemIndex(index: 2)
        self.sessionUnreadCount = totalUnreadCount
        self.refreshSessionBadge()
    }
    
    func didUpdate(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        self.sessionUnreadCount = totalUnreadCount
        self.refreshSessionBadge()
        //         self.tabBar.showshowBadgeOnItemIndex(index: 2)
    }
    
    func didRemove(_ recentSession: NIMRecentSession, totalUnreadCount: Int) {
        // self.tabBar.hideBadgeOnItemIndex(index: 2)
        self.sessionUnreadCount = totalUnreadCount;
        self.refreshSessionBadge()
        
    }
    
    func allMessagesDeleted() {
        // self.tabBar.hideBadgeOnItemIndex(index: 2)
        self.sessionUnreadCount = 0
        self.refreshSessionBadge()
    }
    func refreshSessionBadge() {
        if self.sessionUnreadCount == 0 {
             self.message.setImage(UIImage.init(named: "messagenotip"), for: .normal)
        } else {
            self.message.setImage(UIImage.init(named: "messagetip"), for: .normal)
        }
    }
    
    func LoginYunxin(){
        
        //        SVProgressHUD.showErrorMessage(ErrorMessage: "失败", ForDuration: 2.0, completion: nil)
        if checkLogin(){
        let registerWYIMRequestModel = RegisterWYIMRequestModel()
        registerWYIMRequestModel.name_value = UserDefaults.standard.object(forKey: "phone") as? String  ?? "123"
        registerWYIMRequestModel.phone = UserDefaults.standard.object(forKey: "phone") as? String ?? "123"
        registerWYIMRequestModel.uid = Int(StarUserModel.getCurrentUser()?.id ?? 0)
        
        print( "====  \(registerWYIMRequestModel)" )
        
        AppAPIHelper.login().registWYIM(model: registerWYIMRequestModel, complete: { (result) in
            if let datadic = result as? Dictionary<String,String> {
                
                let phone = UserDefaults.standard.object(forKey: "phone") as! String
                let token = (datadic["token_value"]!)
                
                NIMSDK.shared().loginManager.login(phone, token: token, completion: { (error) in
                    if (error == nil) {
                        
                        NIMSDK.shared().systemNotificationManager.add(self)
                        NIMSDK.shared().conversationManager.add(self)
                        self.sessionUnreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
                        
                        print("未读消息条数====\(self.sessionUnreadCount)")
                    }
                })
            }
        }) { (error) in
            
        }
    }
    }
}
