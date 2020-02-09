//
//  VehicleTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/9/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit
import CoreData

class VehicleTableViewController: UIViewController {
    @IBOutlet weak var vehicleTableView: UITableView!
    var vehicles: [NSManagedObject] = []
    var dealerId: Int?
    lazy var delegate = VehicleTableViewDelegate(viewController: self)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleTableView.delegate = delegate
        vehicleTableView.dataSource = delegate
    }
}
