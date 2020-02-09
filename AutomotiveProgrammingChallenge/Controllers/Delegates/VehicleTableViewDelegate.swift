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
        fetchVehicleData()
    }
}

extension VehicleTableViewDelegate: UITableViewDelegate {
    private func fetchVehicleData() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Vehicle")
            
            do {
                //LUCAS - only fetch the ones matching the dealerId
                self.vehicles = try managedContext.fetch(fetchRequest)
                self.viewController?.vehicleTableView.reloadData()
            } catch let error as NSError {
                print("Could not fetch vehicles with errors - \(error), \(error.userInfo)")
            }
        }
    }
}

extension VehicleTableViewDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vehicles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let vehicle = vehicles[indexPath.row]
        //LUCAS - fix this optional
        cell.textLabel?.text = "\(String(describing: vehicle.value(forKeyPath: "vehicleId") as? Int))"
        return cell
    }
}
