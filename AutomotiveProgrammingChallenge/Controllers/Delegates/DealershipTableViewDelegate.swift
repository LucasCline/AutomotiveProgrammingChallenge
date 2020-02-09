//
//  DealershipTableViewDelegate.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit
import CoreData

class DealershipTableViewDelegate: NSObject {
    weak var viewController: DealershipTableViewController?
    var dealerIds: Set<Int> = []
    var vehicles: [NSManagedObject] = []
    var dealerships: [NSManagedObject] = []
    
    init(viewController: DealershipTableViewController) {
        super.init()
        self.viewController = viewController
        
        fetchDealershipData()
        //deleteCoreData()
    }
    
    //debugging only - only deletes dealership data
    private func deleteCoreData() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            //2
            let fetchRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSManagedObject>(entityName: "Dealership") as! NSFetchRequest<NSFetchRequestResult>)
            
            //3
            do {
                try managedContext.execute(fetchRequest)
                self.viewController?.dealershipTableView.reloadData()
                //self.dealerships = try managedContext.fetch(fetchRequest)
                //self.viewController?.dealershipTableView.reloadData()
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    private func fetchDealershipData() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Dealership")
            
            do {
                self.dealerships = try managedContext.fetch(fetchRequest)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            if self.dealerships.count > 0 {
                self.viewController?.dealershipTableView.reloadData()
            } else {
                self.loadDealershipData()
            }
        }
    }
    
    private func saveVehicleInfo(_ vehicleInfo: VehicleInfo) {
        DispatchQueue.main.async {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Vehicle", in: managedContext)!
            let vehicle = NSManagedObject(entity: entity, insertInto: managedContext)
            
            vehicle.setValue(vehicleInfo.dealerId, forKeyPath: "dealerId")
            vehicle.setValue(vehicleInfo.make, forKey: "make")
            vehicle.setValue(vehicleInfo.model, forKey: "model")
            vehicle.setValue(vehicleInfo.vehicleId, forKey: "vehicleId")
            vehicle.setValue(vehicleInfo.year, forKey: "year")
            
            do {
                try managedContext.save()
                self.vehicles.append(vehicle)
            } catch let error as NSError {
                print("Could not save core data object vehicle with errors - \(error), \(error.userInfo)")
            }
        }
    }
    
    private func saveDealershipInfo(_ dealershipInfo: DealershipInfo) {
        DispatchQueue.main.async {
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Dealership", in: managedContext)!
            let dealership = NSManagedObject(entity: entity, insertInto: managedContext)
            
            dealership.setValue(dealershipInfo.id, forKey: "id")
            dealership.setValue(dealershipInfo.name, forKey: "name")
            
            do {
                try managedContext.save()
                self.dealerships.append(dealership)
            } catch let error as NSError {
                print("Could not save core data object dealership with errors - \(error), \(error.userInfo)")
            }
        }
    }
    
    private func loadDealershipData() {
        let networkingManager = NetworkingManager()
        //get a datasetId
        networkingManager.getDatasetId { (datasetId) in
            //get the list of vehicles provided by a given datasetId
            networkingManager.getVehicleList(datasetId: datasetId) { (datasetId, vehicleIds) in
                //create a dispatch group to signal when all of the dealership requests have finished
                let vehicleDispatchGroup = DispatchGroup()
                //for each vehicle id in the list, request the data for the vehicle
                vehicleIds.forEach { (vehicleId) in
                    vehicleDispatchGroup.enter()
                    networkingManager.getVehicleInfo(datasetId: datasetId, vehicleId: vehicleId) { (datasetId, vehicleInfo) in
                        vehicleDispatchGroup.leave()
                        //persist vehicle info
                        self.saveVehicleInfo(vehicleInfo)
                        self.dealerIds.insert(vehicleInfo.dealerId)
                    }
                }
                
                vehicleDispatchGroup.notify(queue: .main) {
                    print("finished the vehicle requests")
                    let dealershipDispatchGroup = DispatchGroup()
                    self.dealerIds.forEach { (dealerId) in
                        dealershipDispatchGroup.enter()
                        networkingManager.getDealershipInfo(datasetId: datasetId, dealerId: dealerId) { (datasetId, dealershipInfo) in
                            dealershipDispatchGroup.leave()
                            self.saveDealershipInfo(dealershipInfo)
                            print(dealershipInfo)
                        }
                    }
                    
                    dealershipDispatchGroup.notify(queue: .main) {
                        self.fetchDealershipData()
                    }
                }
            }
        }
    }
}

extension DealershipTableViewDelegate: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DealershipTableViewDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dealerships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let dealership = dealerships[indexPath.row]
        cell.textLabel?.text = dealership.value(forKeyPath: "name") as? String
        return cell
    }
}
