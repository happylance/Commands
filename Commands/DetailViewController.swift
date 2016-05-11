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
                textView.textAlignment = .Left
                textView.editable = false
                let result = Utils.executeCmd(detail as? String ?? "uname -a")
                switch result {
                case .Success:
                    textView.text = result.value
                case .Failure:
                    textView.text = result.error?.localizedDescription
                }
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

