//
//  MasterViewController.swift
//  Commands
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit

struct Constants {
    static let commandsKey = "Commands"
    static let defaults = NSUserDefaults.standardUserDefaults()
}

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var commands = (Constants.defaults.arrayForKey(Constants.commandsKey) as? [String]) ?? [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.commands = (Constants.defaults.arrayForKey(Constants.commandsKey) as? [String]) ?? [String]()
        self.commands = self.commands.sort()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Please type a command", preferredStyle: UIAlertControllerStyle.Alert)
        var inputTextField: UITextField?;
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action)->() in
            let command = inputTextField?.text ?? "ls -lah"
            if command.isEmpty {
                return
            }
            
            let index = self.commands.binarySearch{$0 < command}
            self.commands.insert(command, atIndex: index)
            Constants.defaults.setObject(self.commands, forKey: Constants.commandsKey)
            Constants.defaults.synchronize()
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }))
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            textField.placeholder = "Enter command:"
            inputTextField = textField
        })
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = commands[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                CommandHelper.latestCommand = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commands.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let object = commands[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {

        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit", handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            let alert = UIAlertController(title: nil, message: "Please update your command", preferredStyle: UIAlertControllerStyle.Alert)
            var inputTextField: UITextField?;
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
                (action)->() in
                let command = inputTextField?.text ?? ""
                if command.isEmpty {
                    return
                }
                
                cell?.textLabel!.text = command
                self.commands[indexPath.row] = command
                Constants.defaults.setObject(self.commands, forKey: Constants.commandsKey)
                Constants.defaults.synchronize()
            }))
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter command:"
                textField.text = cell?.textLabel!.text
                inputTextField = textField
            })
            self.presentViewController(alert, animated: true, completion: nil)
        });
        editRowAction.backgroundColor = UIColor.blueColor();
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            self.commands.removeAtIndex(indexPath.row)
            Constants.defaults.setObject(self.commands, forKey: Constants.commandsKey)
            Constants.defaults.synchronize()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        });
        
        return [deleteRowAction, editRowAction];
    }
}

