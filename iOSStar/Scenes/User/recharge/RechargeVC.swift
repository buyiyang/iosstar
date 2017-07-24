//
//  RechargeVC.swift
//  iOSStar
//
//  Created by sum on 2017/4/26.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class RechargeVC: BaseTableViewController ,WXApiDelegate,UITextFieldDelegate{
    
    var rid = ""
    
    @IBOutlet var collectView: RechargeCollectView!

    @IBOutlet var dobuy: UIButton!
    var selectTypeHeight = CGFloat.init(140)
    //选中支付方式银行卡号
    @IBOutlet weak var payTypeNumber: UILabel!
    //选中支付的银行
    @IBOutlet weak var payTypeName: UILabel!
    //输入金额
    @IBOutlet weak var inputMoney: UITextField!
    //选中支付方式的图片
    var selectBtn : Bool = false
    @IBOutlet weak var payTypeImg: UIImageView!
    var  payView : SelectPayType!
    var  rechargeMoney : Double = 0.00
    var  bgview : UIView!
    var  paytype  = Int()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(paysuccess(_:)), name: Notification.Name(rawValue:AppConst.WechatPay.WechatKeyErrorCode), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(alipaysuccess(_:)), name: Notification.Name(rawValue:AppConst.aliPay.aliPayCode), object: nil)
        title = "充值"
       
        collectView.resultBlock =  { [weak self](result) in
        
            self?.inputMoney.text = result as? String
            self?.rechargeMoney = Double.init((result as? String)!)!
        }
      
        dobuy.backgroundColor = UIColor.init(hexString: AppConst.Color.orange)
        inputMoney.delegate = self
        inputMoney.keyboardType = .decimalPad
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        loadview()
        
    }
     //MARK支付宝充值成功回调充值
    func alipaysuccess(_ notice: NSNotification) {
        if let errorCode: Int = notice.object as? Int{
            if errorCode == 9000 {
                SVProgressHUD.showSuccessMessage(SuccessMessage:"充值成功", ForDuration: 2.0, completion: nil)
                return
            } else if errorCode == 6001 {
                cancelRecharge()
                SVProgressHUD.showErrorMessage(ErrorMessage:"支付取消", ForDuration: 2.0, completion: nil)
                return
            } else {
                SVProgressHUD.showErrorMessage(ErrorMessage:"支付失败", ForDuration: 2.0, completion: nil)
                return
            }
        }

    }
    //MARK:微信充值成功回调充值
    func paysuccess(_ notice: NSNotification) {
        if let errorCode: Int = notice.object as? Int{
            if errorCode == 0 {
                SVProgressHUD.showSuccessMessage(SuccessMessage: "充值成功", ForDuration: 2.0, completion: nil)
                return  
            }
            else if errorCode == -4{
                SVProgressHUD.showErrorMessage(ErrorMessage: "支付失败", ForDuration: 2.0, completion: nil)
                return
            }
            else if errorCode == -2{
                cancelRecharge()
                SVProgressHUD.showErrorMessage(ErrorMessage: "用户中途取消", ForDuration: 2.0, completion: nil)
                return
            }
        }
    }
    func textFieldDidChange(_ textFile : NSNotification) {
        if inputMoney.text != "" {
            if Double.init(inputMoney.text!)! > 50000 {
                SVProgressHUD.showErrorMessage(ErrorMessage: "金额不能大于50000", ForDuration: 2.0, completion: nil)
                inputMoney.text = ""
                collectView.setSelect = "true"
                return
            }
            collectView.setSelect = "true"
            rechargeMoney = Double.init(inputMoney.text!)!
        }
    }
    
    // 限制只能输入2位小数点
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let expression = "^[0-9]*((\\.|,)[0-9]{0,2})?$"
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        return numberOfMatches != 0
    }
    
    
    //MARK:去充值
    @IBAction func doRecharge(_ sender: Any) {
        //微信充值
        if rechargeMoney == 0.0 {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入充值金额", ForDuration: 2.0, completion: nil)
            return
        }
        if paytype == 0 {
           doWeiXinPay()
        } else {
           doAliPay()
        }

    }

    
    //MARK:选择充值金额
    @IBAction func chooseRechargeMoney(_ sender: Any) {
        if selectBtn == false{
            selectBtn = true
            inputMoney.text = ""
            rechargeMoney = 0.0
        }
        
        let moneyStr = String(stringInterpolationSegment:((sender as! UIButton).tag))
       
        inputMoney.text = moneyStr
        inputMoney.resignFirstResponder()
        let btn = sender as! UIButton
        if rechargeMoney != 0.0{
//            let vi :UIButton =  self.view.viewWithTag(Int.init(rechargeMoney)) as! UIButton
//            vi.backgroundColor = UIColor.white
//            vi.setTitleColor(UIColor.init(hexString: AppConst.Color.orange), for: .normal)
//            rechargeMoney = Double.init(btn.tag)
//            btn.backgroundColor = UIColor.init(hexString: AppConst.Color.orange)
//            btn.setTitleColor(UIColor.white, for: .normal)
//            rechargeMoney = Double.init(btn.tag)
        }else{
            btn.backgroundColor = UIColor.init(hexString: AppConst.Color.orange)
            btn.setTitleColor(UIColor.white, for: .normal)
            rechargeMoney = Double.init(btn.tag)
            
        }
    }
    
    //MARK:tableView datasource
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 10
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0.001 : 10
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
        if indexPath.section == 0 {
            inputMoney.resignFirstResponder()
            tableView.isScrollEnabled = false
            tableView.bringSubview(toFront: bgview)
            UIView.animate(withDuration: 0.4, animations: {
                self.payView.frame = CGRect.init(x: 0, y: tableView.frame.size.height - self.selectTypeHeight, width: tableView.frame.size.width, height: self.selectTypeHeight)
            })
        }
    }
    //MARK: loadview添加支付方式的view
    func loadview(){
        bgview = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
        bgview.backgroundColor = UIColor.init(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        tableView.addSubview(bgview)
        
        let btn = UIButton.init(type: .custom)
        btn.frame = bgview.frame
        bgview.addSubview(btn)
        btn.addTarget(self, action: #selector(clickBg), for: .touchUpInside)
        payView =  Bundle.main.loadNibNamed("SelectPayType", owner: nil, options: nil)?.last as? SelectPayType
        payView.frame = CGRect.init(x: 0, y: tableView.frame.size.height + 500, width: tableView.frame.size.width, height: 200)
        payView.resultBlock = {[weak self](result) in
            
            self?.tableView.isScrollEnabled = true
            let object = result
            if object is Int {
                self?.tableView.sendSubview(toBack: (self?.bgview)!)
                UIView.animate(withDuration: 0.25, animations: {
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.payView.frame = CGRect.init(x: 0, y: ((self?.tableView.frame.size.height)! + (self?.selectTypeHeight)!), width: (self?.tableView.frame.size.width)!, height: (self?.selectTypeHeight)!)
                    })
                }, completion: { (result ) in
                    self?.payView.frame = CGRect.init(x: 0, y: ((self?.tableView.frame.size.height)! + 500), width: (self?.tableView.frame.size.width)!, height: (self?.selectTypeHeight)!)
                })
            }else{
                let model  = result as! SelectPayTypeModel
                self?.payTypeName.text = model.id == 0 ? "微信" : "支付宝"
                
                self?.paytype = model.id
                self?.payTypeImg.image = UIImage.init(named: model.img)
            }
        }
        tableView.sendSubview(toBack: bgview)
        bgview.addSubview(payView)
        
    }
    func clickBg(){
        self.tableView.sendSubview(toBack: (self.bgview)!)
        UIView.animate(withDuration: 0.25, animations: {
            UIView.animate(withDuration: 0.5, animations: {
                self.payView.frame = CGRect.init(x: 0, y: ((self.tableView.frame.size.height) + (self.selectTypeHeight)), width: (self.tableView.frame.size.width), height: (self.selectTypeHeight))
            })
        }, completion: { (result ) in
            self.payView.frame = CGRect.init(x: 0, y: ((self.tableView.frame.size.height) + 500), width: (self.tableView.frame.size.width), height: (self.selectTypeHeight))
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - 支付处理
extension RechargeVC {
    
    fileprivate func doAliPay() {
        
        SVProgressHUD.show(withStatus: "加载中")
        let requestModel = AliPayRequestModel()
        requestModel.title = "余额充值"
        requestModel.price = rechargeMoney
        AppAPIHelper.user().alipay(requestModel: requestModel, complete: { (result) in
            SVProgressHUD.dismiss()
            if let model = result as? AliPayResultModel {
                self.rid = model.rid
                self.openAliPay(orderInfo: model.orderinfo)
            }
        }) { (error) in
            
        }
        
    }

    func cancelRecharge() {
        let requestModel = CancelRechargeModel()
        requestModel.rid = rid
        requestModel.payResult = 1

        AppAPIHelper.user().cancelRecharge(requestModel: requestModel, complete: { (response) in
            
            
        }) { (error) in
            
            
        }
    }
    
    func openAliPay(orderInfo:String) {
        AlipaySDK.defaultService().payOrder(orderInfo, fromScheme: "iOSStar") { (result) in
        }
    }
    
    fileprivate func doWeiXinPay() {
    
        SVProgressHUD.show(withStatus: "加载中")
        let requestModel = WeChatPayModel()
        requestModel.title = "余额充值"
        requestModel.price = rechargeMoney
        AppAPIHelper.user().wechatPay(requestModel: requestModel, complete: { (result) in
            SVProgressHUD.dismiss()
            if let model = result as? WeChatPayResultModel {
                self.rid = model.rid
                let request : PayReq = PayReq()
                request.timeStamp = UInt32(model.timestamp)!
                request.sign = model.sign
                request.package = model.package
                request.nonceStr = model.noncestr
                request.partnerId = model.partnerid
                request.prepayId = model.prepayid
                WXApi.send(request)
            }
        }) { (error) in
            SVProgressHUD.dismiss()
            print(error)
        }
    }
}
