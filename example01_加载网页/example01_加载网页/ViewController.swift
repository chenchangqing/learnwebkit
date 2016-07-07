//
//  ViewController.swift
//  example01_加载网页
//
//  Created by green on 16/7/7.
//  Copyright © 2016年 xyz.chenchangqing. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITextFieldDelegate, WKNavigationDelegate {
    
    var webView: WKWebView
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    // MARK: - Life cycle
    
    required init(coder aDecoder: NSCoder) {
        webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)!
        webView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加webview
        view.insertSubview(webView, belowSubview: progressView)
        
        // 添加webview约束
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[webView]-0-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["webView":webView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[webView]-44-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: ["webView":webView]))
        
        // 调整barView大小
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        
        // 在程序启动时，我们将会打开一个默认页
        if let url = NSURL(string:"http://www.appcoda.com") {
            
            let request = NSURLRequest(URL:url)
            webView.loadRequest(request)
        }
        
        // 使得这个类成为了loading、estimatedProgress属性的监听者
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        // 不希望后退和前进按钮在App被启动时就可点击
        backButton.enabled = false
        forwardButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: - 在设备方向改变时重新设置barView的大小
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 30)
    }
    
    // MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // 后退和前进按钮将根据当前webview的状态来决定是否可被点击
        if (keyPath == "loading") {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
        }
        // 更新progressview的进度，如果加载完毕会隐藏progressview
        if (keyPath == "estimatedProgress") {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        
        if let url = NSURL(string: urlField.text!) {
            
            webView.loadRequest(NSURLRequest(URL: url))
        }
        return false
    }
    
    // MARK: - WKNavigationDelegate
    
    // 错误处理
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // 完成加载处理
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    // MARK: - Action
    
    @IBAction func back(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reload(sender: UIBarButtonItem) {
        let request = NSURLRequest(URL:webView.URL!)
        webView.loadRequest(request)
    }

}

