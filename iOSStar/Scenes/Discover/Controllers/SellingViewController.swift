//
//  SellingViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/8.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class SellingViewController: UIViewController {
    @IBOutlet weak var sureBuyButton: UIButton!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    //倒计时剩余时间
    var remainingTime = 0
    
    var starInfoModel:PanicBuyInfoModel?
    var countTf = UITextField()
    var starModel:StarSortListModel?
    var sectionHeights = [200, 70, 50, 65, 60, 50]
    var identifiers = [SellingIntroCell.className(), SellingTimeAndCountCell.className(), SellingCountDownCell.className(), SellingBuyCountCell.className(), SellingPriceCell.className(), SellingTipsCell.className()]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发售"
        setPriceWithPrice(price: 0)
        requestRemainTime()
        requestPanicBuyStarInfo()

        YD_CountDownHelper.shared.countDownRefresh = { [weak self] (result) in
            

            if self!.remainingTime > 0 {
                
                self?.remainingTime -= 1
            }
            
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? SellingCountDownCell {
                cell.setRemainingTime(count: self!.remainingTime)
            }
            
            
        }
        YD_CountDownHelper.shared.start()
    }
    deinit {
        YD_CountDownHelper.shared.countDownRefresh = nil    
    }
    
    func setPriceWithPrice(price:Double) {

        guard starModel != nil else {
            return
        }
        if starModel!.pushlish_type == 4 {
            sureBuyButton.backgroundColor = UIColor.gray
            sureBuyButton.isUserInteractionEnabled = false
        }
        let priceString = String(format: "%.2f", price)
        let text = "合计: ￥\(priceString)"
        
        totalPriceLabel.setAttributeText(text: text, firstFont: 16, secondFont: 16, firstColor: UIColor(hexString: "333333"), secondColor: UIColor(hexString: "FB9938"), range: NSRange(location: 4, length: text.length() - 4))
        
        totalPriceLabel.setNeedsDisplay()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.HideLine()
    }
    func requestRemainTime() {
        guard starModel != nil else {
            return
        }
        
        let requestModel = BuyRemainingTimeRequestModel()
        requestModel.symbol = starModel!.symbol
        AppAPIHelper.discoverAPI().requestBuyRemainingTime(requestModel: requestModel, complete: { (response) in
            
            if let model = response as? BuyRemainingTimeModel {
                self.remainingTime = Int(model.remainingTime)
            }
        }) { (error) in
            
        }
    }
    
    func requestPanicBuyStarInfo() {
        guard starModel != nil else {
            return
        }
        let requestModel = PanicBuyRequestModel()
        requestModel.symbol = starModel!.symbol
        AppAPIHelper.discoverAPI().requsetPanicBuyStarInfo(requestModel: requestModel, complete: { (response) in
    
            if let model = response as? PanicBuyInfoModel {
                self.starInfoModel = model

                self.tableView.reloadData()
            }
        }) { (error) in
            
        }
        
    }

    @IBAction func buyAction(_ sender: Any) {
        
        guard starModel != nil else {
            return
        }
        guard countTf.text != "" else {
            SVProgressHUD.showErrorMessage(ErrorMessage: "请输入购买数量", ForDuration: 1, completion: nil)
            return
        }
        if ( Int64.init(countTf.text!)!) == 0 {
           SVProgressHUD.showErrorMessage(ErrorMessage: "购买数量大于0", ForDuration: 1, completion: nil)
        }
        else if ( ( Int64.init(countTf.text!)!) > (starInfoModel?.publish_last_time)!){
            SVProgressHUD.showErrorMessage(ErrorMessage: "最多购买"  + "\(String(describing: starInfoModel?.publish_last_time))" + "秒", ForDuration: 1, completion: nil)

        }
        
        let requestModel = BuyStarTimeRequestModel()
  
        requestModel.amount = Int64.init(countTf.text!)!
        requestModel.price = (self.starInfoModel?.publish_price)!
        requestModel.symbol = starModel!.symbol
        
        AppAPIHelper.discoverAPI().buyStarTime(requestModel: requestModel, complete: { (response) in
            if let result = response?["result"] as? Int{
                if result == 1{
                   SVProgressHUD.showSuccessMessage(SuccessMessage: "购买成功", ForDuration: 1, completion: { 
                    self.navigationController?.popViewController(animated: true)
                   })
                 }else{
                  SVProgressHUD.showErrorMessage(ErrorMessage: "交易失败", ForDuration: 1, completion: nil)
                }
            }else{
              SVProgressHUD.showErrorMessage(ErrorMessage: "交易失败", ForDuration: 1, completion: nil)
            }
        }) { (error) in
            SVProgressHUD.showErrorMessage(ErrorMessage: "交易失败", ForDuration: 1, completion: nil)
            
        }
    }
}

extension SellingViewController:UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.tableView.contentOffset = CGPoint(x: 0, y: 200)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(sectionHeights[indexPath.row])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifiers.count
    }
    
    func countChange(sender:UITextField) {
        if sender.text != nil {
            if let price = Double(sender.text!) {
                setPriceWithPrice(price: price * (starInfoModel?.publish_price ?? 0))
                
            }
        } else {
            setPriceWithPrice(price: 0)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifiers[indexPath.row]!, for: indexPath)
        switch indexPath.row {
        case 2:
            if let countDownCell = cell as? SellingCountDownCell {
                countDownCell.setRemainingTime(count:remainingTime)
            }
        case 3:
            if let buyCountCell = cell as? SellingBuyCountCell {
                buyCountCell.countTextField.delegate = self
                countTf = buyCountCell.countTextField
                buyCountCell.countTextField.addTarget(self, action: #selector(countChange(sender:)), for: .editingDidEnd)
              
            }
        case 5:
            if let tipsCell = cell as? SellingTipsCell {
                return tipsCell
            }
        default:
            break
        }
        if let baseCell = cell as? SellingBaseCell {
            baseCell.setPanicModel(model: starInfoModel)
        }
        return cell
    }
    
}
