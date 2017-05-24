//
//  DealScrollView.swift
//  iOSStar
//
//  Created by J-bb on 17/5/23.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
protocol DealScrollViewScrollDelegate {
    
    func scrollToIndex(index:Int)
}

class DealScrollView: UIView,UIScrollViewDelegate {

    var delegate:DealScrollViewScrollDelegate?
    lazy var scrollView:UIScrollView = {
        
       let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 64))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
        
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.frame = frame
        scrollView.isPagingEnabled = true
        
    }

    func setSubViews(customSubViews:[UIView]) {
       scrollView.contentSize = CGSize(width: CGFloat(customSubViews.count) * kScreenWidth, height: 0)
        for (index, view) in customSubViews.enumerated() {
            view.frame = CGRect(x: CGFloat(index) * kScreenWidth, y: 0, width: kScreenWidth, height: frame.size.height - 64)
            scrollView.addSubview(view)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let index = scrollView.contentOffset.x / kScreenWidth
            delegate?.scrollToIndex(index: Int(index))
        }
    }
    
    func moveToIndex(index:Int) {
        UIView.animate(withDuration: 0.5) {
            self.scrollView.contentOffset = CGPoint(x: CGFloat(index), y: 0)
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}