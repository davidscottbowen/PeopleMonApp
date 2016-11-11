//
//  CaughtTableViewController.swift
//  PeopleMon
//
//  Created by David  Bowen on 11/10/16.
//  Copyright © 2016 David  Bowen. All rights reserved.
//

import UIKit

class CaughtTableViewController: UITableViewController {
    
   var caught: [People] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let people = People()
        people.requestType = .caught
        WebServices.shared.getObjects(people) { (objects, error) in
            if let objects = objects {
                self.caught = objects
                print(self.caught)
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("This is the array count size \(caught.count)")
     
       return caught.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CaughtTableViewCell", for: indexPath) as? CaughtTableViewCell {
            let people = caught[indexPath.row]
            cell.setupCell(people: people)
            return cell
        } else {
            
            print("Cell Error")
            
            return UITableViewCell()
        }
    }
}
