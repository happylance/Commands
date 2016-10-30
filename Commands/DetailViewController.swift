//
//  DetailViewController.swift
//  Commands
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var detailTextView: UITextView!

    var isConfigured = false
    var detailItem: String? {
        didSet {
            // Update the view.
            isConfigured = false
            self.configureView()
        }
    }

    func configureView() {
        if isConfigured {
            return
        }
        
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let textView = self.detailTextView {
                isConfigured = true
                let cmd = detail
                textView.textAlignment = .left
                textView.isEditable = false
                textView.text = "$ \(cmd) ..."
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async(execute: {
                    let result = Utils.executeCmd(cmd)
                    DispatchQueue.main.async(execute: {
                        if cmd != CommandHelper.latestCommand {
                            print("Ignore the result of '\(cmd)' because the latest command now is '\(CommandHelper.latestCommand)'")
                            return
                        }
                        
                        let animation: CATransition = CATransition()
                        animation.duration = 0.5
                        animation.type = kCATransitionFade
                        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        textView.layer.add(animation, forKey: "changeTextTransition")
                        
                        switch result {
                        case .success:
                            textView.text = "$ \(cmd)\n\(result.value!)"
                        case .failure:
                            textView.text = "$ \(cmd)\n\(result.error?.localizedDescription ?? "")"
                        }
                    })
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.detailTextView.text = ""
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

