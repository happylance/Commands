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

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let textView = self.detailTextView {
                let cmd = detail as? String ?? "uname -a"
                textView.textAlignment = .Left
                textView.editable = false
                textView.text = "Executing '\(cmd)' ..."
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let result = Utils.executeCmd(cmd)
                    dispatch_async(dispatch_get_main_queue(), {
                        if cmd != CommandHelper.latestCommand {
                            print("Ingore the result of '\(cmd)' because the latest command now is '\(CommandHelper.latestCommand)'")
                            return
                        }
                        
                        let animation: CATransition = CATransition()
                        animation.duration = 0.5
                        animation.type = kCATransitionFade
                        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                        textView.layer.addAnimation(animation, forKey: "changeTextTransition")
                        
                        switch result {
                        case .Success:
                            textView.text = "\(textView.text) Done.\n\(result.value!)"
                        case .Failure:
                            textView.text = "\(textView.text) Done.\n\(result.error?.localizedDescription)"
                        }
                    })
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

