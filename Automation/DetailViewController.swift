//
//  DetailViewController.swift
//  Automation
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit
import NMSSH

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
                let configFilePath = NSBundle.mainBundle().pathForResource("config", ofType: nil);
                let config = NMSSHConfig(fromFile:configFilePath)
                
                let session = NMSSHSession(host:"ec2", configs:[config], withDefaultPort: 22, defaultUsername: "ubuntu")
                session.connect()
                if session.connected {
                    let privateKey = NSBundle.mainBundle().pathForResource("ec2", ofType: "pem");
                    session.authenticateByPublicKey(nil, privateKey: privateKey, andPassword: nil)
                    if (session.authorized) {
                        print("Authentication succeeded");
                    }
                }
                
                var error : NSError? = nil
                let response = session.channel.execute(detail as? String ?? "uname -a", error:&error, timeout:10)
                if let error = error {
                    print(error)
                    let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                print(response)
                session.disconnect()
                /*
                
                BOOL success = [session.channel uploadFile:@"~/index.html" to:@"/var/www/9muses.se/"];
                
                [session disconnect];*/
                
                textView.textAlignment = .Left
                textView.text = response
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

