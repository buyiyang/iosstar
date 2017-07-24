//
//  HeatListViewController.swift
//  iOSStar
//
//  Created by J-bb on 17/7/11.
//  Copyright © 2017年 YunDian. All rights reserved.
//

import UIKit
import MJRefresh
class HeatListViewController: UITableViewController {
    var imageNames:[String]?
    var dataSource:[StarSortListModel]?
    let header = MJRefreshNormalHeader()
    let footer = MJRefreshAutoNormalFooter()
    var Index = 1
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(NoDataCell.self, forCellReuseIdentifier: "NoDataCell")
        tableView.reloadData()
        configImageNames()
        setupNav()
        inittableview()
    }
    func inittableview(){
    
        Index = 1
      
        header.setRefreshingTarget(self, refreshingAction: #selector(didRequest(_:)))
        self.tableView!.mj_header = header
        self.tableView.mj_header.beginRefreshing()
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(didRequestMore(_:)))
        self.tableView!.mj_footer = footer

    
    }

    override func didRequest(_ pageIndex: Int) {

        let requestModel = StarSortListRequestModel()
         requestModel.pos = Int64((Index - 1) * 10)
        requestModel.count = 10
        AppAPIHelper.discoverAPI().requestStarList(requestModel: requestModel, complete: { (response) in
            if let models = response as? [StarSortListModel] {
              
                self.tableView.mj_header.endRefreshing()
                self.dataSource = models
                self.tableView.reloadData()
              
               
            }
            
        }) { (error) in
            
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    func didRequestMore(_ pageIndex: Int) {
        Index = Index + 1
        let requestModel = StarSortListRequestModel()
        requestModel.pos = Int64((Index - 1) * 10)
        requestModel.count = 10
        AppAPIHelper.discoverAPI().requestStarList(requestModel: requestModel, complete: { (response) in
            if let models = response as? [StarSortListModel] {
                self.tableView.mj_footer.endRefreshing()
                self.dataSource?.append(contentsOf: models)
                self.tableView.reloadData()
        
            }
            
        }) { (error) in
            self.tableView.mj_footer.endRefreshing()
            self.tableView.reloadData()
        }
    }
    @IBAction func searchAction(_ sender: Any) {
        let stroyBoard = UIStoryboard(name: AppConst.StoryBoardName.Markt.rawValue, bundle: nil)
        let vc =  stroyBoard.instantiateViewController(withIdentifier: MarketSearchViewController.className())
        navigationController?.pushViewController(vc, animated: true)
    }
    func configImageNames()  {
        imageNames = []
        for index in 0...10 {
            imageNames?.append("starList_back\(index)")
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.dataSource == nil ? UIScreen.main.bounds.size.height - 150 : 130
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.dataSource == nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataCell.className(), for: indexPath) as! NoDataCell
            cell.imageView?.image = UIImage.init(named: "nodata")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: HeatListCell.className(), for: indexPath) as! HeatListCell
        cell.update(dataSource![indexPath.row])
        cell.setBackImage(imageName: (imageNames?[indexPath.row % 10])!)
        return cell
    }
    func setupNav() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named:"white_back"), for: .normal)
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        let item = UIBarButtonItem(customView: button)
        navigationItem.backBarButtonItem = item
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        self.performSegue(withIdentifier: "ToDeal", sender: indexPath)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDeal" {
            let indexPath = sender as! IndexPath
            if let vc = segue.destination as? HeatDetailViewController {

                vc.imageName = imageNames![indexPath.row % 10]
                vc.starListModel = dataSource![indexPath.row]
            }
            
        }
    }




}
