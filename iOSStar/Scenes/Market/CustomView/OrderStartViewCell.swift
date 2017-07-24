//
//  OrderStartViewCell.swift
//  iOSStar
//
//  Created by MONSTER on 2017/5/25.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import SVProgressHUD

// MARK: - 自定义按钮
class OrderItemButton : UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView?.contentMode = .center
        self.imageView?.contentMode = .scaleAspectFit
        self.titleLabel?.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 调整图片的位置
        self.imageView?.centerX = self.width * 0.5
        self.imageView?.y = 0
        self.imageView?.height = self.height * 0.75
        
        // 调整文字的位置
        self.titleLabel?.x = 0;
        self.titleLabel?.width = self.width;
        self.titleLabel?.y = (self.imageView?.height)!
        self.titleLabel?.height = self.height - (self.imageView?.height)!
    }
}

// MARK: - 自定义布局
class CustomLayout: UICollectionViewFlowLayout {
    
    weak var dataSource: CustomLayoutDataSource?
    
    fileprivate lazy var rols: Int? = {
        return self.dataSource?.numberOfRols(self)
    }()
    
    fileprivate lazy var cols: Int? = {
        return self.dataSource?.numberOfCols(self)
    }()
    
    fileprivate lazy var attrsArray: [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
        super.prepare()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        //        let page = indexPath.item%(rols*cols) == 0 ? indexPath.item/(rols*cols) : (indexPath.item/(cols*rols) + 1)
        guard let rols = dataSource?.numberOfRols(self), let cols = dataSource?.numberOfCols(self) else {
            fatalError("请实现对应的数据源方法(行数和列数)")
        }
        let page = indexPath.item / (cols * rols)//页数
        let cellW = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - (CGFloat(cols - 1) * minimumInteritemSpacing)) / CGFloat(cols)
        let itemRow = CGFloat((indexPath.item - page*(cols*rols)) / cols)//行数
        let itemCol = CGFloat((indexPath.item - page*(cols*rols)) % cols)//列数
        let cellX = CGFloat(page) * collectionView!.bounds.width + CGFloat(itemCol) * (cellW + 10) + sectionInset.left
        let cellH: CGFloat = (collectionView!.bounds.height - sectionInset.top - sectionInset.bottom - (CGFloat(rols - 1)) * minimumLineSpacing) / CGFloat(rols)
        let cellY = itemRow * (cellH + sectionInset.top) + sectionInset.top
        attribute.frame = CGRect(x: cellX, y: cellY, width: cellW, height: cellH)
        return attribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        for i in 0..<itemCount {
            let attr = layoutAttributesForItem(at: IndexPath(item: i, section: 0))
            attrsArray.append(attr!)
        }
        return attrsArray
    }
    
    override var collectionViewContentSize: CGSize {
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        guard let rols = dataSource?.numberOfRols(self), let cols = dataSource?.numberOfCols(self) else {
            fatalError("请实现对应的数据源方法(行数和列数)")
        }
        let page = itemCount%(cols*rols) == 0 ? itemCount/(cols*rols) : itemCount/(cols*rols) + 1
        
        return CGSize(width: CGFloat(page) * collectionView!.bounds.width, height: 0)
    }
}
// 自定义布局数据源方法
protocol CustomLayoutDataSource: class {
    func numberOfCols(_ customLayout: CustomLayout) -> Int
    func numberOfRols(_ customLayout: CustomLayout) -> Int
}


// MARK: - UICollectionViewCell
class OrderStarItem: UICollectionViewCell {
    
    // 服务类型button
    @IBOutlet weak var serviceTypeButton: OrderItemButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        serviceTypeButton.isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setServiceType(_ serviceTypeModel : ServiceTypeModel) {
        
        serviceTypeButton.setTitle(serviceTypeModel.name, for: .normal)
        // serviceTypeButton.setImage(UIImage(named: "kefu_QQ"), for: .normal)
        // serviceTypeButton.setImage(UIImage(named: "kefu_weixin"), for: .selected)
            
        if serviceTypeModel.url1 == "" {
            serviceTypeButton.setImage(UIImage(named: "kefu_QQ"), for: .normal)
        } else {
            serviceTypeButton.kf.setImage(with: URL(string: serviceTypeModel.url1),for: .normal)
        }
        if serviceTypeModel.url2 == "" {
            serviceTypeButton.setImage(UIImage(named: "kefu_weixin"), for: .selected)
        } else {
            serviceTypeButton.kf.setImage(with: URL(string: serviceTypeModel.url2),for: .selected)
        }
    }
}
private let KOrderStarItemID = "OrderStarItemID"

// MARK : - UITableViewCell
class OrderStartViewCell: UITableViewCell,UICollectionViewDelegate,UICollectionViewDataSource,CustomLayoutDataSource{

    // 分页控件
    @IBOutlet weak var pageControl: UIPageControl!
    
    // collectionView
    @IBOutlet weak var orderStartCollectionView: UICollectionView!
    
    // 模型数组
    var serviceTypeModel : [ServiceTypeModel]?
    
    var ordercell : OrderStarItem?

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        setupInit();
    }
    
    func setStarServiceType(serviceModel:[ServiceTypeModel]?) {
        self.serviceTypeModel = serviceModel
        self.orderStartCollectionView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    @IBAction func add(_ sender: Any) {
  
    }
    // MRAK: -布局UI
    func setupInit() {
        
        orderStartCollectionView.delegate = self
        orderStartCollectionView.dataSource = self
        
        // 自定义布局
        let layout = CustomLayout()
        layout.dataSource = self
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        self.orderStartCollectionView.collectionViewLayout = layout
        layout.scrollDirection = .horizontal
        
        self.orderStartCollectionView.showsVerticalScrollIndicator = false
        self.orderStartCollectionView.showsHorizontalScrollIndicator = false
        self.orderStartCollectionView.isPagingEnabled = true
        
    }
    
    // MRAK: -UICollectionView  DataSource AND Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let serviceTypeModelCount = serviceTypeModel?.count ?? 0
        
        // 分页
        let pageNum = (serviceTypeModelCount - 1) / 8 + 1
        if serviceTypeModelCount == 0 {
            pageControl.numberOfPages = 0
        } else {
            pageControl.numberOfPages = pageNum
        }
        
        return serviceTypeModelCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if serviceTypeModel?.count ?? 0 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KOrderStarItemID, for: indexPath) as! OrderStarItem
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: KOrderStarItemID, for: indexPath) as! OrderStarItem
        cell.setServiceType(serviceTypeModel![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell =  collectionView.cellForItem(at: indexPath) as! OrderStarItem
        // 记录
        self.ordercell?.serviceTypeButton.isSelected = false
        
        cell.serviceTypeButton.isSelected = true
        
        self.ordercell = cell
        
        
        if self.serviceTypeModel?.count ?? 0 == 0 {
            return
        }
       
        let serviceTypeModel = self.serviceTypeModel![indexPath.row]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: AppConst.chooseServiceTypeSuccess), object: serviceTypeModel, userInfo: nil)
        
        // print("点击了\(indexPath.row) + 服务名称\(serviceTypeModel.name)");
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
    }

    // MRAK: -自定义layout的代理方法
    func numberOfCols(_ customLayout: CustomLayout) -> Int {
        return 4
    }
    func numberOfRols(_ customLayout: CustomLayout) -> Int {
        return 2
    }
    
    
    
}

