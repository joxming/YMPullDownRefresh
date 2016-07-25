//
//  DemoViewController.swift
//  YMPullDownRefresh
//
//  Created by mimi on 16/7/25.
//  Copyright © 2016年 mimi. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //添加工具
        tableView.addSubview(refreshTool)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

    }

    
    var tableView:UITableView = UITableView()
    var refreshTool:YMPullDownRefresh = YMPullDownRefresh()
}


extension DemoViewController:UITableViewDataSource,UITableViewDelegate{

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //点击停止刷新
        refreshTool.endRefreshing()
    }
    
    
    
    
       //以下废代码
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        return cell
    }
}