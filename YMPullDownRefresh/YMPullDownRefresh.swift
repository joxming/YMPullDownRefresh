//
//  YMPullDownRefresh.swift
//  YMPullDownRefresh
//
//  Created by mimi on 16/7/25.
//  Copyright © 2016年 mimi. All rights reserved.
//

import UIKit

//状态管理枚举

enum YMPullDownRefreshState: Int {
    // 正常-默认状态
    case Normal = 0
    // 下拉中
    case Pulling = 1
    // 刷新中
    case Refresh = 2
}


//下拉工具条的高度
let refreshControlH: CGFloat = 50

class YMPullDownRefresh: UIControl {
    var scrollView: UIScrollView?
    
    //状态记录
    
    var ymState:YMPullDownRefreshState = .Normal{
        
        didSet{
            
            switch ymState {
            case .Normal:
               messageLabel.text = "正常"
                UIView.animateWithDuration(0.25, animations: { 
                 self.pullImageView.transform = CGAffineTransformIdentity
                })
               //判断上一个状态是否为刷新
               if oldValue == .Refresh{
                UIView.animateWithDuration(0.25, animations: { 
                    self.scrollView?.contentInset.top -= refreshControlH
                    }, completion: { (_) in
                        //显示箭头
                        self.pullImageView.highlighted = false
                        //停止动画
                        self.indicatorView.stopAnimating()
                        
                })
                
               }

            case .Pulling:
                messageLabel.text = "下拉中"
                UIView.animateWithDuration(0.25, animations: { 
                   self.pullImageView.transform = CGAffineTransformMakeRotation(CGFloat(-3*M_PI))
                })
            case .Refresh:
                messageLabel.text = "刷新中"
                pullImageView.hidden = true
                indicatorView.startAnimating()
                UIView.animateWithDuration(0.25, animations: { 
                    self.scrollView?.contentInset.top += refreshControlH
                    }, completion: { (_) in
                     //告知外界刷新
                        self.sendActionsForControlEvents(.ValueChanged)
                })
            }
        }
  
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: -refreshControlH, width: UIScreen.mainScreen().bounds.width, height: refreshControlH))
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //        MARK: - 停止
    func endRefreshing() {
        
        ymState = .Normal
    }

    //        MARK: - 该控件加载到的父控件- 获取父控件 ,监听操作
    override func willMoveToSuperview(newSuperview: UIView?) {
        
        guard let scrollView = newSuperview as? UIScrollView else{
            return
        }
        self.scrollView = scrollView
    //        MARK: - 使用KVO监听 (不能用代理,防止外界使用代理)
        self.scrollView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        
    }
    
    //        MARK: - 得到scrollView的变化
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
       getYMrefreshControlState(self.scrollView!.contentOffset.y)
    }
    
    func getYMrefreshControlState(contentOffsetY: CGFloat) {
        
        let contenInsetTop = self.scrollView?.contentInset.top ?? 0
        
        //代表用户在拖动
        if self.scrollView!.dragging{
            if contentOffsetY > -contenInsetTop - refreshControlH && ymState == .Pulling{
                ymState = .Normal
            }else if contentOffsetY <= -contenInsetTop - refreshControlH && ymState == .Normal{
                ymState = .Pulling
            }
            
        }else{
            //代表不拖动了
            if ymState == .Pulling{
                ymState = .Refresh
            }
        }
    }
    
    //        MARK: - 设置视图
    
    func setupUI() {
        backgroundColor = UIColor.orangeColor()
        //add控件
        addSubview(messageLabel)
        addSubview(pullImageView)
        addSubview(indicatorView)
        
        //约束控件
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        pullImageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: pullImageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -35))
        addConstraint(NSLayoutConstraint(item: pullImageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -35))
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
    }
    
    //        MARK: - 懒加载控件
    //label
    private lazy var messageLabel: UILabel = {
        let lab = UILabel()
        lab.text = "正常"
        lab.textColor = UIColor.whiteColor()
        lab.font = UIFont.systemFontOfSize(14)
        return lab
    }()
    //箭头
    private lazy var pullImageView:UIImageView = UIImageView(image: UIImage(named:"tableview_pull_refresh"))
    //菊花
    private lazy var indicatorView:UIActivityIndicatorView = {
       let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        return view
    }()
    
    //        MARK: - 在结束移除监听
    deinit{
        self.scrollView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
}










