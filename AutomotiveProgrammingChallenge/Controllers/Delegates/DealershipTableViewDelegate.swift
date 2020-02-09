//
//  DealershipTableViewDelegate.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class DealershipTableViewDelegate: NSObject {
    weak var viewController: DealershipTableViewController?
    var vehicleInfoList: [VehicleInfo] = []
    var dealerIds: Set<Int> = []
    var dealershipInfoList: [DealershipInfo] = []
    init(viewController: DealershipTableViewController) {
        super.init()
        self.viewController = viewController
        loadDealershipData()
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
                        self.vehicleInfoList.append(vehicleInfo)
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
                            self.dealershipInfoList.append(dealershipInfo)
                        }
                    }
                    
                    dealershipDispatchGroup.notify(queue: .main) {
                        print("finished the dealership requests")
                        self.viewController?.dealershipTableView.reloadData()
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
        return self.dealershipInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(self.dealershipInfoList[indexPath.row].name)"
        return cell
    }
}
