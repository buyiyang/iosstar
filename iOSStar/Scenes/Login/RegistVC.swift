//
//  RegistVC.swift
//  iOSStar
//
//  Created by sum on 2017/4/20.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class RegistVC: UIViewController ,UIGestureRecognizerDelegate{
    
    @IBOutlet weak var ThreeLoginLabel: UILabel!
    @IBOutlet weak var wechatLogoImageView: UIImageView!
    @IBOutlet weak var wechatLoginLabel: UILabel!
    
    @IBOutlet weak var rbackView: UIView!
    @IBOutlet weak var rcontentView: UIView!
    
    @IBOutlet var left: NSLayoutConstraint!
    
    @IBOutlet var hava_account: UIButton!
    
    @IBOutlet weak var registeredButton: UIButton!
    //时间戳
    var timeStamp =  ""
    //token
    var vToken = ""
    //右边距
    @IBOutlet var right: NSLayoutConstraint!
    //上边距
    @IBOutlet var top: NSLayoutConstraint!
    //定义block来判断选择哪个试图
    var resultBlock: CompleteBlock?
    @IBOutlet weak var codeTf: UITextField!
    
    @IBOutlet var phoneTf: UITextField!
    //定时器
    private var timer: Timer?
    //验证码
    @IBOutlet weak var vaildCodeBtn: UIButton!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var width: NSLayoutConstraint!
    @IBOutlet var passTf: UITextField!
    //验证码
    private var codeTime = 60
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    
        
    }
    
    func initUI(){
        
        codeTf.keyboardType =  .numberPad
        registeredButton.backgroundColor = UIColor.init(hexString: AppConst.Color.main)
        hava_account.titleLabel?.setAttributeText(text: "已有账户 现在注册", firstFont: 14, secondFont: 14, firstColor: UIColor.init(hexString: "999999"), secondColor: UIColor.init(hexString: AppConst.Color.main), range: NSRange(location: 5, length: 4))
        let h  = UIScreen.main.bounds.size.height <= 568 ? 70.0 : 90
        self.top.constant = UIScreen.main.bounds.size.height/568.0 * CGFloat.init(h)
        print(self.top.constant)
        self.left.constant = UIScreen.main.bounds.size.width/320.0 * 30
        self.right.constant = UIScreen.main.bounds.size.width/320.0 * 30
        height.constant = 100 + UIScreen.main.bounds.size.height
        width.constant = UIScreen.main.bounds.size.width

    
        let rbackViewTap = UITapGestureRecognizer.init(target: self, action: #selector(rbackViewTapClick))
        rbackViewTap.delegate = self
        rbackView.addGestureRecognizer(rbackViewTap)
        
        ShareDataModel.share().addObserver(self, forKeyPath: "isweichaLogin", options: .new, context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "isweichaLogin" {
            if let Ischange = (change? [NSKeyValueChangeKey.newKey] as? Bool) {
                if Ischange == false {
//            if (change? [NSKeyValueChangeKey.newKey] as? Bool) == false {
                self.registeredButton.setTitle("注册", for: .normal)
                    self.ThreeLoginLabel.isHidden = false
                    self.wechatLogoImageView.isHidden = false
                    self.wechatLoginLabel.isHidden = false
            } else {
               self.registeredButton.setTitle("微信绑定", for: .normal)
                    self.ThreeLoginLabel.isHidden = true
                    self.wechatLogoImageView.isHidden = true
                    self.wechatLoginLabel.isHidden = true
            }
        }
    }
}
    deinit {
        ShareDataModel.share().removeObserver(self, forKeyPath: "isweichaLogin", context: nil)
    }
    
    // 拦截中间contentView的点击事件
  
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: rcontentView))! {
            return false;
        }
        
        return true;
    }

    func rbackViewTapClick() {
        
        let win  : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let tabar  : BaseTabBarController = win.rootViewController as! BaseTabBarController
        tabar.selectedIndex = 0
        self.dismissController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title =  "注册"
        initUI()
        
    }
    
    //17682310986
    //MARK:-   发送验证码
    @IBAction func sendVaildCode(_ sender: Any) {
        

        if checkTextFieldEmpty([phoneTf]) && isTelNumber(num: phoneTf.text!) {
            vaildCodeBtn.isEnabled = false
            let checkRegisterRequestModel = CheckRegisterRequestModel()
            checkRegisterRequestModel.phone = phoneTf.text!
            AppAPIHelper.login().CheckRegister(model: checkRegisterRequestModel, complete: {[weak self] (checkRegistResult) in
                if let checkRegistResponse = checkRegistResult {
                    if let result = checkRegistResponse["result"] as? Int {
                        if result == 1 {
                            SVProgressHUD.showErrorMessage(ErrorMessage: "该用户已注册,请登录", ForDuration: 2.0, completion: nil)
                            self?.vaildCodeBtn.isEnabled = true
                        } else {
                            SVProgressHUD.showProgressMessage(ProgressMessage: "")
                            let sendVerificationCodeRequestModel = SendVerificationCodeRequestModel()
                            sendVerificationCodeRequestModel.phone = (self?.phoneTf.text!)!
                            AppAPIHelper.login().SendVerificationCode(model: sendVerificationCodeRequestModel, complete: { [weak self] (result) in
                                SVProgressHUD.dismiss()
                                self?.vaildCodeBtn.isEnabled = true
                                if let response = result {
                                    if response["result"] as! Int == 1 {
                                        self?.timer = Timer.scheduledTimer(timeInterval: 1,target:self!,selector: #selector(self?.updatecodeBtnTitle),userInfo: nil,repeats: true)
                                        self?.timeStamp = String.init(format: "%ld", response["timeStamp"] as!  Int)
                                        self?.vToken = String.init(format: "%@", response["vToken"] as! String)
                                    }
                                }
                            }, error: { (error) in
                                self?.didRequestError(error)

                                self?.vaildCodeBtn.isEnabled = true
                            })
                        }
                    }
                }
            }, error: { (error) in
                self.didRequestError(error)
//                SVProgressHUD.showErrorMessage(ErrorMessage: error.userInfo["NSLocalizedDescription"] as! String, ForDuration: 2.0, completion: nil)
                self.vaildCodeBtn.isEnabled = true
            })
        }
    }
    //MARK:-   更新秒数
    func updatecodeBtnTitle() {
        if codeTime == 0 {
            vaildCodeBtn.isEnabled = true
            vaildCodeBtn.setTitle("重新发送", for: .normal)
            codeTime = 60
            timer?.invalidate()
            
            vaildCodeBtn.backgroundColor = UIColor(hexString: "BCE0DA")
            return
        }
        vaildCodeBtn.isEnabled = false
        codeTime = codeTime - 1
        let title: String = "\(codeTime)秒重新发送"
        vaildCodeBtn.setTitle(title, for: .normal)
        
        vaildCodeBtn.backgroundColor = UIColor(hexString: "ECECEC")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
      //MARK:-   注册
    @IBAction func doregist(_ sender: Any) {
        
        if !checkTextFieldEmpty([phoneTf,codeTf,passTf]) {
            return
        }
        if !isTelNumber(num: phoneTf.text!){
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入正确的手机号码", ForDuration: 2.0, completion: nil)
            return
        }
        if !isPassWord(pwd: passTf.text!) {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入6位字符以上密码", ForDuration: 2.0, completion: nil)
            return
        }
        if ShareDataModel.share().isweichaLogin == true && ShareDataModel.share().wechatUserInfo[SocketConst.Key.openid] != "" {
            bindWeChat()
        }
        else {
            login()
        }

    }
    //MARK:-  regist()
    
    func login() {

//        FIXME: - 此处先给"123456"的验证码
        /*
        if codeTf.text != "123456" {
            SVProgressHUD.showErrorMessage(ErrorMessage: "验证码错误", ForDuration: 2.0, completion: nil)
            return
        }
        */
        let string = "yd1742653sd" + self.timeStamp + self.codeTf.text! + self.phoneTf.text!
        if string.md5_string() != self.vToken{
            SVProgressHUD.showErrorMessage(ErrorMessage: "验证码错误", ForDuration: 1.0, completion: nil)
            return
        }
        ShareDataModel.share().registerModel.phone = phoneTf.text!
        ShareDataModel.share().registerModel.pwd = passTf.text!.md5_string()
        resultBlock!(doStateClick.doJoin as AnyObject?)
    }
    
    // MARK: - 微信绑定注册
    func bindWeChat() {
        let string = "yd1742653sd" + self.timeStamp + self.codeTf.text! + self.phoneTf.text!
        if string.md5_string() != self.vToken{
            SVProgressHUD.showErrorMessage(ErrorMessage: "验证码错误", ForDuration: 2.0, completion: nil)
            return
        }
        
        ShareDataModel.share().wxregisterModel.openid = ShareDataModel.share().wechatUserInfo[SocketConst.Key.openid]!
        ShareDataModel.share().wxregisterModel.nickname = ShareDataModel.share().wechatUserInfo[SocketConst.Key.nickname]!
        ShareDataModel.share().wxregisterModel.headerUrl = ShareDataModel.share().wechatUserInfo[SocketConst.Key.headimgurl]!
        ShareDataModel.share().wxregisterModel.phone = phoneTf.text!
        ShareDataModel.share().wxregisterModel.pwd = passTf.text!.md5_string()
        resultBlock!(doStateClick.doJoin as AnyObject?)
    }
       //MARK:-   去登录
    @IBAction func doLogin(_ sender: Any) {
        view.endEditing(true)
        self.phoneTf.text = ""
        self.passTf.text = ""
        self.codeTf.text = ""
        self.resultBlock!(doStateClick.doLogin as AnyObject?)
    }
    // MARK - 微信登录
    @IBAction func weichatLogin(_ sender: Any) {
        let req = SendAuthReq.init()
        req.scope = AppConst.WechatKey.Scope
        req.state = AppConst.WechatKey.State
        WXApi.send(req)
    }
    //MARK:-   忘记密码
    @IBAction func doResetPass(_ sender: Any) {
        self.resultBlock!(doStateClick.doResetPwd as AnyObject)
    }
    
    //MARK:- 网易云登录
    func LoginYunxin(){
        
        let registerWYIMRequestModel = RegisterWYIMRequestModel()
        registerWYIMRequestModel.name_value = phoneTf.text!
        registerWYIMRequestModel.phone = phoneTf.text!
        
        registerWYIMRequestModel.uid = Int(StarUserModel.getCurrentUser()?.id ?? 0)
//        registerWYIMRequestModel.accid_value = phoneTf.text!
        AppAPIHelper.login().registWYIM(model: registerWYIMRequestModel, complete: { [weak self](result) in
            if let datadic = result as? Dictionary<String,String> {
//            if let _ = datadic {
                UserDefaults.standard.set(self?.phoneTf.text, forKey: "phone")
                UserDefaults.standard.set((datadic["token_value"])!, forKey: "tokenvalue")
                UserDefaults.standard.synchronize()
                NIMSDK.shared().loginManager.login((self?.phoneTf.text!)!, token: (self?.passTf.text!)!, completion: { (error) in
                    if (error != nil){
                            self?.dismissController()
                    }
                })
            }
        }) { (error) in
            
        }
    }
    
    @IBAction func didMiss(_ sender: Any) {
        let win  : UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let tabar  : BaseTabBarController = win.rootViewController as! BaseTabBarController
        if tabar.selectedIndex == 1{

        }
        else{
            tabar.selectedIndex = 0
        }
        
        
        
        self.dismissController()
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
    }
    
}
