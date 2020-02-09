//
//  DealershipTableViewDelegate.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class DealershipTableViewDelegate: NSObject {
    weak var viewController: DealershipTableViewController?
    init(viewController: DealershipTableViewController) {
        self.viewController = viewController
    }
}

extension DealershipTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hey")
    }
}

extension DealershipTableViewDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewController!.dealershipInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(self.viewController!.dealershipInfoList[indexPath.row].name)"
        return cell
    }
}
