//
//  NotificationsTableViewController.swift
//  Virtue
//
//  Created by Ruohan Ding on 3/2/18.
//  Copyright © 2018 Ding. All rights reserved.
//

import UIKit

class NotificationsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.shadowImage = UIColor.groupTableViewBackground.imageFromColor()
        tableView.tableFooterView = UIView()
        let notificationImageView = NotificationTableImageView.instanceFromNib()
        tableView.backgroundView = notificationImageView
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell")
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }
}

class NotificationTableImageView: UIView {
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "NotificationTableImageView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
}
