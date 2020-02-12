//
//  DealershipTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class DealershipTableViewController: UIViewController {
    @IBOutlet weak var dealershipTableView: UITableView!
    lazy var delegate = DealershipTableViewDelegate(viewController: self)
    var dealerIdForSegue: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        dealershipTableView.delegate = delegate
        dealershipTableView.dataSource = delegate
        
        let networkingManager = NetworkingManager()
        networkingManager.downloadAndSaveAllAPIData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? VehicleTableViewController else {
            return
        }
        
        destinationVC.dealerId = dealerIdForSegue
    }
}
