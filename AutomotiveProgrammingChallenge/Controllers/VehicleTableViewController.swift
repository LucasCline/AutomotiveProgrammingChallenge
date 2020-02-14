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
    var newVehicles: [VehicleInfo] = []
    var dealerId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleTableView.delegate = self
        vehicleTableView.dataSource = self
        
        fetchVehicleData()
    }
    
    func fetchVehicleData() {
        DataProvider.getVehicleData { response in
            switch response {
            case .success(let allVehicles):
                //LUCAS - remove this filter - since we added vehicles to dealers
                self.newVehicles = allVehicles.filter { $0.dealerId == self.dealerId }
                DispatchQueue.main.async {
                    self.vehicleTableView.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                //LUCAS - handle no data found 
                break
            }
        }
    }
}

extension VehicleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension VehicleTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newVehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VehicleCell", for: indexPath) as? VehicleTableViewCell else {
            print("Unable to cast the table view cell to a VehicleCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }
        
        let vehicle = newVehicles[indexPath.row]

        cell.yearMakeModel.text = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
        cell.vehicleId.text = "Vehicle ID: \(vehicle.vehicleId)"
        cell.dealershipId.text = "Dealership ID: \(vehicle.dealerId)"
        
        return cell
    }
}
