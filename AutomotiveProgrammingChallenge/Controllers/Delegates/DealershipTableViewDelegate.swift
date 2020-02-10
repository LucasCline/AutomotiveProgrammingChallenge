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
    }
    
    //fetch dealership data from core data -- if none found, make a request to the server
    //
    private func fetchDealershipData() {
        CoreDataManager.shared.fetchEntity(entityName: "Dealership") { (dealerships) in
            if dealerships.count == 0 {
                self.loadDealershipData()
            } else {
                self.dealerships = dealerships
                self.viewController?.dealershipTableView.reloadData()
            }
        }
    }
    
    //LUCAS - Rework this
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
                        CoreDataManager.shared.saveVehicleInfo(vehicleInfo)
                        self.dealerIds.insert(vehicleInfo.dealerId)
                    }
                }
                
                vehicleDispatchGroup.notify(queue: .main) {
                    print("finished the vehicle requests")
                    let dealershipDispatchGroup = DispatchGroup()
                    self.dealerIds.forEach { (dealerId) in
                        dealershipDispatchGroup.enter()
                        networkingManager.getDealershipInfo(datasetId: datasetId, dealerId: dealerId) { (datasetId, dealershipInfo) in
                            CoreDataManager.shared.saveDealershipInfo(dealershipInfo) {
                                dealershipDispatchGroup.leave()
                            }
                        }
                    }
                    
                    //once the dealership data is retrieved from the server, read from core data again.
                    //LUCAS - will this endlessly loop if server fails?
                    //LUCAS - maybe moving this to completion handler style format is a better idea
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
        let dealerId = dealerships[indexPath.row].value(forKey: "id") as? Int
        viewController?.dealerIdForSegue = dealerId
        viewController?.performSegue(withIdentifier: "VehicleSegue", sender: viewController)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DealershipTableViewDelegate: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dealerships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealershipCell", for: indexPath) as? DealershipTableViewCell else {
            print("Unable to cast the table view cell to a DealershipCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }
        
        let dealership = dealerships[indexPath.row]
        
        guard let name = dealership.value(forKeyPath: "name") as? String,
            let id = dealership.value(forKeyPath: "id") as? Int else {
                print("Unable to retrieve dealership values for cell - returning a blank UITableViewCell")
                return UITableViewCell()
        }

        cell.dealershipName.text = name
        cell.dealershipId.text = "ID: \(id))"
        return cell
    }
}
