//
//  VehicleTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/9/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class VehicleTableViewController: UIViewController {
    @IBOutlet weak var vehicleTableView: UITableView!
    var vehicles: [VehicleInfo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleTableView.delegate = self
        vehicleTableView.dataSource = self
        
        if vehicles.count == 0 {
            DispatchQueue.main.async {
                self.displayAlertForNoVehicleDataFound()
            }
        }
    }
    
    private func displayAlertForNoVehicleDataFound() {
        let alert = UIAlertController(title: "Vehicle Data Not Found", message: "There was no vehicle data found for the given Dataset ID.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension VehicleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension VehicleTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as? VehicleTableViewCell else {
            print("Unable to cast the table view cell to a VehicleCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }
        
        let vehicle = vehicles[indexPath.row]

        cell.yearMakeModel.text = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
        cell.vehicleId.text = "Vehicle ID: \(vehicle.vehicleId)"
        cell.dealershipId.text = "Dealership ID: \(vehicle.dealerId)"
        
        return cell
    }
}
