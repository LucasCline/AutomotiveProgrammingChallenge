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
    private var vehicles: [NSManagedObject] = []
    var newVehicles: [VehicleInfo] = []
    var dealerId: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vehicleTableView.delegate = self
        vehicleTableView.dataSource = self
        
        fetchVehicleData()
        
//        CoreDataManager.shared.fetchEntity(entityName: "Vehicle") { (vehicles) in
//            self.vehicles = vehicles.filter { $0.value(forKeyPath: "dealerId") as? Int == self.dealerId }
//            self.vehicleTableView.reloadData()
//        }
    }
    
    func fetchVehicleData() {
        DataProvider().getVehicleData { response in
            switch response {
            case .success(let allVehicles):
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
        //implement any future segue logic here
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
//
//        guard let year = vehicle.value(forKeyPath: "year") as? Int,
//            let make = vehicle.value(forKeyPath: "make") as? String,
//            let model = vehicle.value(forKeyPath: "model") as? String,
//            let vehicleId = vehicle.value(forKeyPath: "dealerId") as? Int,
//            let dealerId = vehicle.value(forKeyPath: "dealerId") as? Int else {
//                print("Unable to retrieve vehicle values for cell - returning a blank UITableViewCell")
//                return UITableViewCell()
//        }
        
        cell.yearMakeModel.text = "\(vehicle.year) \(vehicle.make) \(vehicle.model)"
        cell.vehicleId.text = "Vehicle ID: \(vehicle.vehicleId)"
        cell.dealershipId.text = "Dealership ID: \(vehicle.dealerId)"
        
        return cell
    }
}
