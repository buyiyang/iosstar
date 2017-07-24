//
//  StarNewsVC.swift
//  YStar
//
//  Created by mu on 2017/7/11.
//  Copyright © 2017年 com.yundian. All rights reserved.
//

import UIKit
import YYText
import SVProgressHUD
import MJRefresh

class NewsCell: OEZTableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var newsPic: UIImageView!
    @IBOutlet weak var newsLabel: YYLabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var thumbUpBtn: UIButton!
    @IBOutlet weak var CommentBtn: UIButton!
    @IBOutlet weak var showView: UIView!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        showBtn.setImage(UIImage.imageWith(AppConst.iconFontName.showIcon.rawValue, fontSize: CGSize.init(width: 22, height: 17), fontColor: UIColor.init(rgbHex: AppConst.ColorKey.linkColor.rawValue)), for: .normal)
        showBtnTapped(showBtn)
        thumbUpBtn.setImage(UIImage.imageWith(AppConst.iconFontName.thumbIcon.rawValue, fontSize: CGSize.init(width: 16, height: 16), fontColor: UIColor.init(rgbHex: AppConst.ColorKey.closeColor.rawValue)), for: .normal)
        CommentBtn.setImage(UIImage.imageWith(AppConst.iconFontName.commentIcon.rawValue, fontSize: CGSize.init(width: 16, height: 16), fontColor: UIColor.init(rgbHex: AppConst.ColorKey.closeColor.rawValue)), for: .normal)
        newsLabel.textParser = YParser.share()
    }
    
    override func update(_ data: Any!) {
        if let model = data as? CircleListModel{
            let userIcon = UIImage.imageWith(AppConst.iconFontName.userPlaceHolder.rawValue, fontSize: iconImage.frame.size, fontColor: UIColor.init(rgbHex: AppConst.ColorKey.main.rawValue))
            iconImage.kf.setImage(with: URL.init(string: model.head_url), placeholder: userIcon)
            nameLabel.text =  model.symbol_name
            newsLabel.text = model.content
            //新闻图片占位图
            let newsPlace = UIImage.imageWith(AppConst.iconFontName.newsPlaceHolder.rawValue, fontSize: newsPic.frame.size, fontColor: UIColor.init(rgbHex: AppConst.ColorKey.main.rawValue))
            newsPic.kf.setImage(with: URL.init(string: model.pic_url), placeholder: newsPlace)
            //计算文案高度
            let contentAttribute = NSMutableAttributedString.init(string: model.content)
            contentAttribute.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSRange.init(location: 0, length: model.content.length()))
            let size  = CGSize.init(width: newsLabel.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let layout = YYTextLayout.init(containerSize: size, text: contentAttribute)
            contentHeight.constant = (layout?.textBoundingSize.height)!
        }
    }
    
    @IBAction func showBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        UIView.animate(withDuration: 0.25, animations: { [weak self] (animation) in
            self?.showView.isHidden = sender.isSelected
        })
    }
    
    @IBAction func thumbUpOrCommentBtnTapped(_ sender: UIButton) {
        didSelectRowAction(UInt(sender.tag))
        showBtnTapped(showBtn)
    }
}

class ThumbupCell: OEZTableViewCell {
    @IBOutlet var iconImage: UIImageView!
    @IBOutlet var thumbupNames: UILabel!
    @IBOutlet weak var thumbUpHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        iconImage.image = UIImage.imageWith(AppConst.iconFontName.thumpUpIcon.rawValue, fontSize: iconImage.frame.size, fontColor: UIColor.init(rgbHex: AppConst.ColorKey.main.rawValue))
    }
    
    override func update(_ data: Any!) {
        if let model = data as? CircleListModel{
            var approveName = ""
            for approve in model.approve_list{
                approveName += "\(approve.user_name),"
            }
            //计算文案高度
            let contentAttribute = NSMutableAttributedString.init(string: approveName)
            contentAttribute.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSRange.init(location: 0, length: approveName.length()))
            let size  = CGSize.init(width: thumbupNames.frame.width-40 , height: CGFloat.greatestFiniteMagnitude)
            let layout = YYTextLayout.init(containerSize: size, text: contentAttribute)
            thumbUpHeight.constant = (layout?.textBoundingSize.height)!
            thumbupNames.attributedText = contentAttribute
        }
    }
}

class CommentCell: OEZTableViewCell {
    @IBOutlet var commentLabel: YYLabel!
    @IBOutlet weak var commentHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        let replyGesture = UITapGestureRecognizer.init(target: self, action: #selector(replyGestureTapped(_:)))
        commentLabel.addGestureRecognizer(replyGesture)
        commentLabel.isUserInteractionEnabled = true
        commentLabel.textParser = YParser.share()
    }
    
    func update(_ data: Any!, index:IndexPath) {
        if let listModel = data as? CircleListModel{
            let model = listModel.comment_list[index.row-2]
            var comment = "\(model.user_name):\(model.content)"
            if model.direction == 1{
                comment = "\(listModel.symbol_name)回复\(model.user_name):\(model.content)"
            }
            if model.direction == 2{
                comment = "\(model.user_name)回复\(listModel.symbol_name):\(model.content)"
            }
            //计算文案高度
            let contentAttribute = NSMutableAttributedString.init(string: comment)
            contentAttribute.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 14), range: NSRange.init(location: 0, length: comment.length()))
            let size  = CGSize.init(width: commentLabel.frame.width , height: CGFloat.greatestFiniteMagnitude)
            let layout = YYTextLayout.init(containerSize: size, text: contentAttribute)
            commentHeight.constant = (layout?.textBoundingSize.height)!
            if model.direction == 0 {
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x0092ca), range: NSRange.init(location: 0, length: model.user_name.length()))
            }
            if model.direction == 1{
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x8c0808), range: NSRange.init(location: 0, length: listModel.symbol_name.length()))
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x0092ca), range: NSRange.init(location: listModel.symbol_name.length()+2, length: model.user_name.length()))
                
            }
            if model.direction == 2{
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x8c0808), range: NSRange.init(location: model.user_name.length()+2, length: listModel.symbol_name.length()))
                contentAttribute.addAttribute(NSForegroundColorAttributeName, value: UIColor.init(rgbHex: 0x0092ca), range: NSRange.init(location: 0, length: model.user_name.length()))
            }
            commentLabel.attributedText = contentAttribute
        }
    }
    
    func replyGestureTapped(_ gesture: UITapGestureRecognizer){
        didSelectRowAction(102, data: "")
    }
}

class StarNewsVC: BaseTableViewController, OEZTableViewDelegate {
    
    var tableData: [CircleListModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发现明星"
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.requestCycleData(0)
        })
        tableView.mj_footer = MJRefreshAutoFooter(refreshingBlock: {
            self.requestCycleData(self.tableData.count)
        })
        requestCycleData(0)
    }
    
    enum cellAction: Int {
        case thumbUp = 100
        case comment = 101
        case reply = 102
    }
    
    func endRefresh() {
        if tableView.mj_header.state == .refreshing {
            tableView.mj_header.endRefreshing()
        }
        if tableView.mj_footer.state == .refreshing {
            tableView.mj_footer.endRefreshing()
        }
    }
    
    func requestCycleData(_ position: Int) {
        let param = CircleListRequestModel()
        param.pos = Int64(position)
        AppAPIHelper.circleAPI().requestCircleList(requestModel: param, complete: { [weak self](result) in
            if let data = result as? [CircleListModel]{
                if position == 0{
                    self?.tableData = data
                }else{
                    self?.tableData += data
                }
                self?.tableView.reloadData()
            }
            self?.endRefresh()
        }, error: errorBlockFunc())
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = tableData[section] as? CircleListModel{
            return model.comment_list.count+(model.approve_list.count > 0 ? 2:1)
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = tableData[indexPath.section]
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.className()) as? NewsCell
            cell?.update(model)
            return cell!
        }
        
        if indexPath.row == 1{
            let cell  = tableView.dequeueReusableCell(withIdentifier: ThumbupCell.className()) as? ThumbupCell
            cell?.update(model)
            return cell!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.className()) as? CommentCell
        cell?.update(model, index:indexPath)
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, cellIdentifierForRowAtIndexPath indexPath: IndexPath) -> String? {
        switch indexPath.row {
        case 0:
            return NewsCell.className()
        case 1:
            return ThumbupCell.className()
        default:
            return CommentCell.className()
        }
    }
    override func isSections() -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView!, rowAt indexPath: IndexPath!, didAction action: Int, data: Any!) {
        let model = tableData[indexPath.section]
        switch action {
        case cellAction.thumbUp.rawValue:
            for approve in model.approve_list{
                if approve.uid == (StarUserModel.getCurrentUser()?.userinfo?.id)!{
                    SVProgressHUD.showWainningMessage(WainningMessage: "您已经点赞过了", ForDuration: 2, completion: nil)
                    return
                }
            }
            
            let param = ApproveCircleModel()
            param.star_code = model.symbol
            param.circle_id = model.circle_id
            AppAPIHelper.circleAPI().approveCircle(requestModel: param, complete: { (response) in
                if let result = response as? ResultModel{
                    if result.result == 1{
                        SVProgressHUD.showSuccessMessage(SuccessMessage: "点赞成功", ForDuration: 2, completion: { 
                            let user = ApproveModel()
                            user.uid = (StarUserModel.getCurrentUser()?.userinfo?.id)!
                            user.user_name = (StarUserModel.getCurrentUser()?.userinfo?.agentName)!
                            model.approve_list.append(user)
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        })
                    }
                }
            }, error: errorBlockFunc())
            break
        case cellAction.comment.rawValue:
            let keyboardVC = KeyboardInputViewController()
            keyboardVC.modalPresentationStyle = .custom
            keyboardVC.modalTransitionStyle = .crossDissolve
            keyboardVC.sendMessage = { [weak self] (message) in
                let param = CommentCircleModel()
                param.content = message as! String
                param.star_code = model.symbol
                param.circle_id = model.circle_id
                AppAPIHelper.circleAPI().commentCircle(requestModel: param, complete: { (response) in
                    if let result = response as? ResultModel{
                        if result.result == 1{
                            SVProgressHUD.showSuccessMessage(SuccessMessage: "评论成功", ForDuration: 2, completion: {
                                let comment = CircleCommentModel()
                                comment.uid = Int((StarUserModel.getCurrentUser()?.userinfo?.id)!)
                                comment.user_name = (StarUserModel.getCurrentUser()?.userinfo?.agentName)!
                                comment.direction = 0
                                comment.priority = 0
                                comment.content = message as! String
                                model.comment_list.append(comment)
//                                tableView.reloadRows(at: [indexPath], with: .automatic)
                                tableView.reloadData()
                            })
                        }
                    }
                }, error: self?.errorBlockFunc())
            }
            present(keyboardVC, animated: true, completion: nil)
        case cellAction.reply.rawValue:
            let commentModel = model.comment_list[indexPath.row-2]
            if commentModel.direction != 1{
                return
            }
            let keyboardVC = KeyboardInputViewController()
            keyboardVC.modalPresentationStyle = .custom
            keyboardVC.modalTransitionStyle = .crossDissolve
            keyboardVC.sendMessage = { [weak self](message) in
                let param = CommentCircleModel()
                param.content = message as! String
                param.star_code = model.symbol
                param.circle_id = model.circle_id
                param.direction = 2
                AppAPIHelper.circleAPI().commentCircle(requestModel: param, complete: { (response) in
                    if let result = response as? ResultModel{
                        if result.result == 1{
                            SVProgressHUD.showSuccessMessage(SuccessMessage: "回复成功", ForDuration: 2, completion: {
                                let comment = CircleCommentModel()
                                comment.uid = Int((StarUserModel.getCurrentUser()?.userinfo?.id)!)
                                comment.user_name = (StarUserModel.getCurrentUser()?.userinfo?.agentName)!
                                comment.direction = 2
                                comment.priority = 0
                                comment.content = message as! String
                                model.comment_list.append(comment)
                                tableView.reloadData()
                            })
                        }
                    }
            
                }, error: self?.errorBlockFunc())
            }
            present(keyboardVC, animated: true, completion: nil)
        default:
            print("")
        }
        
    }
}
