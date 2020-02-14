//
//  VehicleTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/9/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

//LUCAS - make rows not selectable or at least deselect them in didselect
class VehicleTableViewController: UIViewController {
    @IBOutlet weak var vehicleTableView: UITableView!
    var dealership: DealershipInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleTableView.delegate = self
        vehicleTableView.dataSource = self
        
        //LUCAS - if no data is found - maybe display a popup saying there was no data found so the user doesnt just see a blank screen
        
    }
}

extension VehicleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension VehicleTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dealership?.vehicles.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as? VehicleTableViewCell else {
            print("Unable to cast the table view cell to a VehicleCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }
        
        guard let vehicle = dealership?.vehicles[indexPath.row] else {
            print("No vehicle information found -- returning a blank UITableViewCell")
            return UITableViewCell()
        }

        cell.yearMakeModel.text = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
        cell.vehicleId.text = "Vehicle ID: \(vehicle.vehicleId)"
        cell.dealershipId.text = "Dealership ID: \(vehicle.dealerId)"
        
        return cell
    }
}
