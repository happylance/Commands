//
//  MasterViewController.swift
//  Commands
//
//  Created by Liu Liang on 5/1/16.
//  Copyright © 2016 Liu Liang. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    var detailViewController: DetailViewController? = nil
    var commands = (Constants.defaults.array(forKey: Constants.commandsKey) as? [String]) ?? [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MasterViewController.insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.commands = (Constants.defaults.array(forKey: Constants.commandsKey) as? [String]) ?? [String]()
        self.commands = self.commands.sorted()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: AnyObject) {
        let alert = UIAlertController(title: nil, message: "Please type a command", preferredStyle: UIAlertControllerStyle.alert)
        var inputTextField: UITextField?;
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action)->() in
            let command = inputTextField?.text ?? "ls -lah"
            if command.isEmpty {
                return
            }
            
            let index = self.commands.binarySearch{$0 < command}
            self.commands.insert(command, at: index)
            Constants.defaults.set(self.commands, forKey: Constants.commandsKey)
            Constants.defaults.synchronize()
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Enter command:"
            inputTextField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = commands[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                
                CommandHelper.latestCommand = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commands.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let object = commands[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Edit", handler:{action, indexpath in
            tableView.setEditing(false, animated: true)
            let alert = UIAlertController(title: nil, message: "Please update your command", preferredStyle: UIAlertControllerStyle.alert)
            var inputTextField: UITextField?;
            let cell = tableView.cellForRow(at: indexPath)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (action)->() in
                let command = inputTextField?.text ?? ""
                if command.isEmpty {
                    return
                }
                
                cell?.textLabel!.text = command
                self.commands[indexPath.row] = command
                Constants.defaults.set(self.commands, forKey: Constants.commandsKey)
                Constants.defaults.synchronize()
            }))
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Enter command:"
                textField.text = cell?.textLabel!.text
                inputTextField = textField
            })
            self.present(alert, animated: true, completion: nil)
        });
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            self.commands.remove(at: indexPath.row)
            Constants.defaults.set(self.commands, forKey: Constants.commandsKey)
            Constants.defaults.synchronize()
            tableView.deleteRows(at: [indexPath], with: .fade)
        });
        
        return [deleteRowAction, editRowAction];
    }

}

