//
//  ViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var vehicleInfoList: [VehicleInfo] = []
    var dealerIds: [Int] = []
    var dealershipInfoList: [DealershipInfo] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let networkingManager = NetworkingManager()
        //get a datasetId
        networkingManager.getDatasetId { (datasetId) in
            //get the list of vehicles provided by a given datasetId
            networkingManager.getVehicleList(datasetId: datasetId) { (datasetId, vehicleIds) in
                //for each vehicle id in the list, request the data for the vehicle
                vehicleIds.forEach { (vehicleId) in
                    networkingManager.getVehicleInfo(datasetId: datasetId, vehicleId: vehicleId) { (datasetId, vehicleInfo) in
                        //persist vehicle info
                        self.vehicleInfoList.append(vehicleInfo)
                        //if we dont already have the dealership data - then request it
                        if !self.dealershipInfoList.contains(where: { $0.id == vehicleInfo.dealerId }) {
                            networkingManager.getDealershipInfo(datasetId: datasetId, dealerId: vehicleInfo.dealerId) { (datasetId, dealershipInfo) in
                                //persist dealership info
                                self.dealershipInfoList.append(dealershipInfo)
                            }
                        } else {
                            print("Found duplicate dealer ID - will not request dealership data again - \(vehicleInfo.dealerId)")
                        }
                    }
                }
            }
        }
    }
}

