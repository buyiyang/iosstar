//
//  BarrageStarVC.swift
//  iOSStar
//
//  Created by sum on 2017/7/14.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import MJRefresh
import SDWebImage
import Kingfisher
class FooterView: UICollectionReusableView {
    @IBOutlet var tipsLb: UILabel!
    
}
import BarrageRenderer
let leftConstant =  (kScreenWidth >= 375 ? ((kScreenWidth/375.0 ) * 18) : 15)
class OrderItem: UICollectionViewCell {
    
    @IBOutlet var nameLb: UILabel!
    @IBOutlet var starImg: UIImageView!
    
    func updata(_ data : AnyObject){
        if let response = data as? StartModel{
            nameLb.text = response.name
            self.starImg.kf.setImage(with: URL(string: response.pic_url))
        }
    }
}
class BarrageStarVC: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    var renderer:BarrageRenderer!
    var headerview = UIView()
    var footerLb = UILabel()
    var imgView = UIImageView()
    var timer : Timer?
    var allData = [BarrageListModel]()
    var index = 0
    //定义一个mjrefrshfooter
    let footer = MJRefreshAutoNormalFooter()
    var dataArry = [StartModel]()
    @IBOutlet var collectView: UICollectionView!
    // MARK: loadView
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "跳蚤市场"
        setupInit()
        buildDanMu()
        initdata()

        // Do any additional setup after loading the view.
    }
  //Mark :创建renderer
    func buildDanMu() {
        self.renderer = BarrageRenderer.init()
        self.renderer.canvasMargin = UIEdgeInsetsMake( 5, 0,50, 0)
        self.renderer.view.backgroundColor = UIColor.init(hexString: "FAFAFA")
    }
    //Mark :更新view
    func autoSenderBarrage() {
        index = index + 1
        if index == allData.count{
            index = 0
        }
        renderer.receive(walkTextSpriteDescriptorWithDirection(direction: BarrageWalkDirection.R2L.rawValue, data: allData[index]))
    }
    //Mark :数据加载
    func walkTextSpriteDescriptorWithDirection(direction:UInt,data : BarrageListModel) -> BarrageDescriptor{
        
        let descriptor:BarrageDescriptor = BarrageDescriptor()
        descriptor.spriteName = NSStringFromClass(YD_Barrage.self)
        
        let attachment = NSTextAttachment()
        imgView.sd_setImage(with: URL.init(string: data.head_url))
        let imgage = imgView.image
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 10
        
        
        if (imgage != nil){
              attachment.image = imgage
        }else{
        
             attachment.image = UIImage.init(named: "avatar_team")
        }
        attachment.bounds = CGRect.init(x: 0, y: -3, width: 18, height: 18)
        let type = data.order_type  == 1 ? "求购" : "转让"
        let name = "  " + data.user_name + type + "\(data.order_num)" + "秒" + "," + "\(data.order_price)" + "秒" + "   "
        let length = 2 + data.user_name.length()
        let color = data.order_type  == 1 ? UIColor.init(hexString: "CB4232") : UIColor.init(hexString: "333333")
        let attributed = NSMutableAttributedString.init(string: name)
        attributed.addAttribute(NSForegroundColorAttributeName, value: color!, range: NSRange.init(location: length, length: 2))
        attributed.insert(NSAttributedString.init(attachment: attachment), at: 1)
        descriptor.params["attributedText"] = attributed;
        descriptor.params["backgroundColor"] = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        descriptor.params["fontSize"] = 15
        descriptor.params["cornerRadius"] = 5
        descriptor.params["textColor"] = UIColor.white
        descriptor.params["speed"] = Int(arc4random()%50) + 50
        descriptor.params["direction"] = direction
        return descriptor
    }
    deinit {
        timer?.invalidate()
        renderer.stop()
    }
    // MARK: 数据请求
    func initdata(){
        
        index = 0
        let requestModel = HeatBarrageModel()
        requestModel.pos = 0
        requestModel.count = 50
        AppAPIHelper.marketAPI().requstBuyBarrageList(requestModel: requestModel, complete: { [weak self](result) in
            if let model = result as? BarrageInfo {
                if (model.barrage_info) != nil{
                    self?.allData = model.barrage_info!
                    self?.timer = Timer.scheduledTimer(timeInterval: 1, target: self ?? BarrageStarVC(), selector: #selector(self?.autoSenderBarrage), userInfo: nil, repeats: true)
                    self?.renderer.start()
                }
               
            }
            
        }) { (error) in
            
        }
        
    }
    // MARK: 自定义布局
    func setupInit() {
        
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize.init(width: self.view.frame.size.width, height: 300)
        layout.footerReferenceSize = CGSize.init(width: self.view.frame.size.width, height: 0)
        layout.minimumLineSpacing = CGFloat.init(leftConstant)
        layout.minimumInteritemSpacing = CGFloat.init(leftConstant)
        layout.itemSize = CGSize.init(width: (self.view.frame.size.width - CGFloat.init(leftConstant) * 5)/4, height: (self.view.frame.size.width - CGFloat.init(leftConstant) * 5)/4 + 20)
        
        self.collectView.collectionViewLayout = layout
        layout.scrollDirection = .vertical
        StartModel.getallStartName { [weak self](result) in
            
            if let model =  result as? [StartModel]{
                self?.dataArry = model
                self?.collectView.reloadData()
            }
        }
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadItemData))
        //是否自动加载（默认为true，即表格滑到底部就自动加载）
        footer.isAutomaticallyRefresh = false
        footer.setTitle("下拉显示更多...", for: .idle)
        footer.stateLabel.textColor = UIColor.init(hexString: "666666")
//        self.collectView!.mj_footer = footer
        footer.stateLabel.font =  UIFont.systemFont(ofSize: 14)
        self.collectView.showsVerticalScrollIndicator = false
        self.collectView.showsHorizontalScrollIndicator = false
        
        
    }
    func loadItemData() {
    
    }
    
    // MARK: collectionView
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderStarItem", for: indexPath) as! OrderItem
        cell.updata(dataArry[indexPath.row])
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets(top: 5, left: CGFloat.init(leftConstant), bottom: 5, right: CGFloat.init(leftConstant))
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath)
        headerview = view
        //        if (add){
        headerview.addSubview(renderer.view)
        return view
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return self.dataArry.count
     }
}
