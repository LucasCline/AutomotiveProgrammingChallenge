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
        
        guard let year = vehicle.value(forKeyPath: "year") as? Int,
            let make = vehicle.value(forKeyPath: "make") as? String,
            let model = vehicle.value(forKeyPath: "model") as? String,
            let vehicleId = vehicle.value(forKeyPath: "dealerId") as? Int,
            let dealerId = vehicle.value(forKeyPath: "dealerId") as? Int else {
                print("Unable to retrieve vehicle values for cell - returning a blank UITableViewCell")
                return UITableViewCell()
        }
        
        cell.yearMakeModel.text = "\(year) \(make) \(model)"
        cell.vehicleId.text = "Vehicle ID: \(vehicleId)"
        cell.dealershipId.text = "Dealership ID: \(dealerId)"
        
        return cell
    }
}
