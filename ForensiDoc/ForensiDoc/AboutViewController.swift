//
//  AboutViewController.swift
//  ForensiDoc

import Foundation

open class AboutViewController: BaseViewController {
    @IBOutlet var webView: UIWebView!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("About ForensiDoc", comment: "About screen title")
        if let path = Bundle.main.path(forResource: "About", ofType: "html") {
            if let requestURL = URL(string:path) {
                let request = URLRequest(url:requestURL);
                webView.loadRequest(request)
            }
        }
    }
    
}
