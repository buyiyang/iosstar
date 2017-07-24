//
//  BuyOrSellViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/5/22.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD
class BuyOrSellViewController: DealBaseViewController {
    var identifiers = ["DealStarInfoCell","DealMarketCell","DealOrderInfoCell"]
    var rowHeights = [137, 188,133,82]

    var infos:[String] = ["转让价格","转让数量"]
    var count = 600
    var price = 0.0
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var orderPriceLabel: UILabel!
    
    @IBOutlet weak var buyOrSellButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        
        if dealType == AppConst.DealType.buy {
            infos  = ["求购价格","求购数量"]
            buyOrSellButton.setTitle("确认求购", for: .normal)
        } else {
            infos = ["转让价格","转让数量"]
            buyOrSellButton.setTitle("确认转让", for: .normal)
        }

        if realTimeData != nil {
            let price = String(format: "%.2f", realTimeData!.currentPrice)
            priceDidChange(totalPrice: Double(price)! * Double(600), count: 600, price: Double(price)!)
        } else {
            requestRealTime()
        }
       requestPositionCount()
     requetTotalCount()
    }
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    func keyboardWillShow(notification: NSNotification?) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: -100, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    func keyboardWillHide(notification: NSNotification?) {
        UIView.animate(withDuration: 0.5) {
            self.view.frame = CGRect(x: self.view.frame.origin.x, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height)
        }
    }
    
    func requetTotalCount() {
        guard starListModel != nil else {
            return
        }
        AppAPIHelper.marketAPI().requestTotalCount(starCode: starListModel!.symbol, complete: { (response) in
            if let model = response as? StarTotalCountModel {
                self.count = Int(model.star_time)
            }
            
        }) { (error) in
            
            
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func buyOrSellAction(_ sender: Any) {

        
        guard starListModel != nil else {
            return
        }
        guard count < totalCount || count == totalCount else {

            SVProgressHUD.showErrorMessage(ErrorMessage: "转让/求购数量不能超过总发行量", ForDuration: 1.5, completion: nil)
            return
        }
        SVProgressHUD.show()
        let model = BuyOrSellRequestModel()
        model.buySell = dealType.rawValue
        model.symbol = starListModel!.symbol
        model.price = price
        model.amount = count
        
        AppAPIHelper.dealAPI().buyOrSell(requestModel: model, complete: { (response) in
            SVProgressHUD.dismiss()
            _ = self.navigationController?.popViewController(animated: true)
            SVProgressHUD.showSuccessMessage(SuccessMessage: "挂单成功", ForDuration: 1.5, completion: nil)
            
        }) { (error) in
            SVProgressHUD.dismiss()
        }
    }
    

    func requestRealTime() {
        let requestModel = RealTimeRequestModel()
        let syModel = SymbolInfo()
        if starListModel != nil {
            syModel.symbol = starListModel!.wid
        } else  {
            return
        }
        requestModel.symbolInfos.append(syModel)
        AppAPIHelper.marketAPI().requestRealTime(requestModel: requestModel, complete: { (response) in
            if let model = response as? [RealTimeModel] {
                self.realTimeData = model.first
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
        }) { (error) in
            
            
        }
    }
    
    func requestPositionCount() {
        guard starListModel != nil else {
            return
        }
        
        let r = PositionCountRequestModel()
        r.starcode = starListModel!.symbol
        AppAPIHelper.marketAPI().requestPositionCount(requestModel: r, complete: { (response) in
            if let model = response as? PositionCountModel {
                self.positionCount = Int(model.star_time)
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
        }) { (error) in

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowEntrustListViewController {
            vc.starCode = starListModel?.symbol
        }
    }
}

extension BuyOrSellViewController:UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, OrderInfoChangeDelegate,ShowEntrustDelegate{
    
    func show() {

        let storyBoard = UIStoryboard(name: "Market", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MarketFansListViewController") as? MarketFansListViewController
        vc?.starCode = starListModel?.symbol
        navigationController?.pushViewController(vc!, animated: true)
    
    }
    
    func priceDidChange(totalPrice: Double, count: Int, price: Double) {
        let priceString = String(format: "%.2f", totalPrice)
        orderPriceLabel.setAttributeText(text: "总价：\(priceString)", firstFont: 18, secondFont: 18, firstColor: UIColor(hexString: "999999"), secondColor: UIColor(hexString: "FB9938"), range: NSRange(location: 3, length: priceString.length()))
        self.count = count
        self.price = price
        if totalPrice == 0 {
            buyOrSellButton.isUserInteractionEnabled = false
            buyOrSellButton.backgroundColor = UIColor(hexString: "CCCCCC")
        } else {
            buyOrSellButton.isUserInteractionEnabled = true
            buyOrSellButton.backgroundColor = UIColor(hexString: AppConst.Color.main)
        }
    }

   
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(rowHeights[indexPath.row])
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return identifiers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifiers[indexPath.row], for: indexPath)
        
        switch indexPath.row {
        case 0:
            if let infoCell = cell as? DealStarInfoCell{
                infoCell.delegate = self
                infoCell.setupData(model:starListModel)
                infoCell.setCount(count:positionCount)
            }
        case 1:
            if let marketCell = cell as? DealMarketCell {
                marketCell.setRealTimeData(model: realTimeData)
            }
        case 2:
            if let orderCell = cell as? DealOrderInfoCell {
                orderCell.count = 600
                orderCell.delegate = self
                orderCell.setTitles(titles: infos)
                guard realTimeData != nil else {
                    return orderCell
                }
                orderCell.price = price
                orderCell.setPriceAndCount(price:price, count:count)
            }
        case 3:
            if let showCell = cell as? DealHintCell {
                showCell.delegate = self
            }
        default:
            break   
        }
        return cell
    }
}
