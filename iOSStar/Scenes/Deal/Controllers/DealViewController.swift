//
//  DealViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/5/22.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit

class DealViewController: RedBackItemViewController,DealScrollViewScrollDelegate,MenuViewDelegate{

    lazy var backView: DealScrollView = {
        let view = DealScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        return view
    }()
    var menuView:YD_VMenuView?
    var starListModel:StarSortListModel?
    var index = 0
    var totalCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuView()
        view.addSubview(backView)
        backView.delegate = self
        addSubViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.HideLine()
    }
    func setupMenuView() {
        navigationController?.navigationBar.setBackgroundImage(UIColor.white.imageWithColor(), for: .default)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (kScreenWidth - 44 - 28) / 5, height: 40)
        layout.sectionInset = UIEdgeInsets(top: -3, left: 0, bottom: 0, right: 28)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection =  .horizontal
        menuView = YD_VMenuView(frame: CGRect(x: 0, y: 0, width: kScreenWidth - 44, height: 40), layout: layout)
        menuView?.backgroundColor = UIColor.clear
        menuView?.isScreenWidth = true
        
        let titles =  ["求购","转让","持有","订单","明细"]
        menuView?.itemData = titles as [AnyObject]?
        menuView?.reloadData()
        menuView?.delegate = self
        navigationItem.titleView = menuView
        perform(#selector(refreshSelect), with: nil, afterDelay: 0.5)
    }
    
    func refreshSelect() {
        menuView?.selected(index: index)
        backView.moveToIndex(index: index)
    }
    func addSubViews() {
        let identifiers = ["BuyOrSellViewController","BuyOrSellViewController","BuyYetViewController","AllOrderViewController","DealDetailViewController"]
        let stroyBoard = UIStoryboard(name: AppConst.StoryBoardName.Deal.rawValue, bundle: nil)
        var views = [UIView]()
        for (index,identifier) in identifiers.enumerated() {
            let vc = stroyBoard.instantiateViewController(withIdentifier: identifier) as! DealBaseViewController
            if index == 0 {
                vc.dealType = AppConst.DealType.buy
            }
            vc.totalCount = totalCount
            vc.starListModel = starListModel
            views.append(vc.view)
            vc.view.frame = CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: backView.frame.size.height - 64)
            addChildViewController(vc)
        }
        backView.setSubViews(customSubViews: views)

    }
    
    
    
    //menuDelegate
    func menuViewDidSelect(indexPath: IndexPath) {
        backView.moveToIndex(index: indexPath.item)
    }
    //backViewDelegate
    func scrollToIndex(index: Int) {
        menuView?.selected(index: index)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
