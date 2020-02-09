//
//  DealershipTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class DealershipTableViewController: UIViewController {
    @IBOutlet weak var dealershipTableView: UITableView!
    
    var vehicleInfoList: [VehicleInfo] = []
    var dealerIds: Set<Int> = []
    var dealershipInfoList: [DealershipInfo] = []
    lazy var delegate = DealershipTableViewDelegate(viewController: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        dealershipTableView.delegate = delegate
        dealershipTableView.dataSource = delegate
        
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
                        self.dealershipTableView.reloadData()
                    }
                }
            }
        }
    }
}
