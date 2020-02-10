//
//  VehicleTableViewDelegate.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/9/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit
import CoreData

class VehicleTableViewDelegate: NSObject {
    weak var viewController: VehicleTableViewController?
    var vehicles: [NSManagedObject] = []
    init(viewController: VehicleTableViewController) {
        super.init()
        
        self.viewController = viewController
        CoreDataManager.shared.fetchEntity(entityName: "Vehicle") { (vehicles) in
            self.vehicles = vehicles.filter { $0.value(forKeyPath: "dealerId") as? Int == viewController.dealerId }
            self.viewController?.vehicleTableView.reloadData()
        }
    }
}

extension VehicleTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        //implement any future segue logic here
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension VehicleTableViewDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as? VehicleTableViewCell else {
            print("Unable to cast the table view cell to a VehicleCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }

        let vehicle = vehicles[indexPath.row]
        //LUCAS - fix these force unwraps
        let year = "\(String(describing: vehicle.value(forKeyPath: "year") as! Int))"
        let make = vehicle.value(forKeyPath: "make") as! String
        let model = vehicle.value(forKeyPath: "model") as! String
        
        cell.yearMakeModel.text = "\(year) \(make) \(model)"
        cell.vehicleId.text = "Vehicle ID: \(String(describing: vehicle.value(forKeyPath: "vehicleId") as! Int))"
        cell.dealershipId.text = "Dealership ID: \(String(describing: vehicle.value(forKeyPath: "dealerId") as! Int))"
        
        return cell
    }
}
