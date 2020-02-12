//
//  NetworkingManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

let datasetIdURL = "http://api.coxauto-interview.com/api/datasetId"
let vehicleListURL = "http://api.coxauto-interview.com/api/"
let vehicleInfoURL = "http://api.coxauto-interview.com/api/"
let dealershipInfoURL = "http://api.coxauto-interview.com/api/"


enum APIError {
    case datasetIdRequestFailed
    case vehicleListRequestFailed
    case vehicleInfoRequestFailed
    case dealershipInfoRequestFailed
}

struct NetworkingManager {
    //LUCAS - This should pass completionHandler as well - so VC knows what to do when done
    //call this something like triggerDownloadOfDealershipAndVehicleData()
    func downloadAndSaveAllAPIData(completionHandler: @escaping () -> ()) {
        triggerDatasetRequest {
            print("finished")
            completionHandler()
        }
    }
    
    func triggerDatasetRequest(completionHandler: @escaping () -> ()) {
        getDatasetId { (datasetId, error) in
            if let error = error {
                print("error found - \(error)")
                return
            }
            
            guard let datasetId = datasetId else {
                print("")
                return
            }
            
            self.triggerVehicleListRequestWith(datasetId: datasetId, completionHandler: completionHandler)
        }
    }
        
    //get the list of vehicles provided by a given datasetId
    func triggerVehicleListRequestWith(datasetId: String, completionHandler: @escaping () -> ()) {
        getVehicleList(datasetId: datasetId) { (dataset, vehicleIds) in
            self.triggerVehicleInfoRequestsWith(datasetId: dataset, vehicleIds: vehicleIds, completionHandler: completionHandler)
        }
    }
        
    func triggerVehicleInfoRequestsWith(datasetId: String, vehicleIds: [Int], completionHandler: @escaping () -> ()) {
        let dispatchGroup = DispatchGroup()
        var dealerIds: Set<Int> = []
        vehicleIds.forEach { (vehicleId) in
            dispatchGroup.enter()
            self.getVehicleInfo(datasetId: datasetId, vehicleId: vehicleId) { (datasetId, vehicleInfo) in
                dealerIds.insert(vehicleInfo.dealerId)
                CoreDataManager.shared.saveVehicleInfo(vehicleInfo) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            print("All vehicle data saved")
            self.triggerDealershipInfoRequestsWith(datasetId: datasetId, dealershipIds: dealerIds, completionHandler: completionHandler)
        }
    }
    
    func triggerDealershipInfoRequestsWith(datasetId: String, dealershipIds: Set<Int>, completionHandler: @escaping () -> ()) {
        let dispatchGroup = DispatchGroup()
        dealershipIds.forEach { (dealershipId) in
            dispatchGroup.enter()
            self.getDealershipInfo(datasetId: datasetId, dealerId: dealershipId) { (dealershipInfo) in
                CoreDataManager.shared.saveDealershipInfo(dealershipInfo) {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            print("All dealership data saved")
            completionHandler()
        }
    }
    

        
    
    private func getDatasetId(completionHandler: @escaping (String?, APIError?) -> ()) {
        guard let url = URL(string: datasetIdURL) else {
            print("Unable to create URL in getDatasetId method")
            completionHandler(nil, APIError.datasetIdRequestFailed)
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDatasetId method received no response from the server")
                completionHandler(nil, APIError.datasetIdRequestFailed)
                return
            }
            
            guard response.isSuccessful else {
                print("getDatasetId method was unsuccessful with response - \(response)")
                completionHandler(nil, APIError.datasetIdRequestFailed)
                return
            }

            guard let data = data else {
                print("getDatasetId method received no data from the server")
                completionHandler(nil, APIError.datasetIdRequestFailed)
                return
            }

            do {
                let dataset = try JSONDecoder().decode(Dataset.self, from: data)
                completionHandler(dataset.id, nil)
            } catch let decodingError {
                print(decodingError)
                completionHandler(nil, APIError.datasetIdRequestFailed)
            }
        }

        task.resume()
    }
    
    private func getVehicleList(datasetId: String, completionHandler: @escaping (String, [Int]) -> ()) {
        guard let url = URL(string: "\(vehicleListURL)\(datasetId)/vehicles") else {
            print("Unable to create URL in getVehicleList method")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getVehicleList method received no response from the server")
                return
            }
            
            guard response.isSuccessful else {
                print("getVehicleList method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                return
            }

            guard let data = data else {
                print("getVehicleList method with datasetId - \(datasetId) received no data from the server")
                return
            }

            do {
                let vehicleList = try JSONDecoder().decode(VehicleList.self, from: data)
                completionHandler(datasetId, vehicleList.ids)
            } catch let decodingError {
                print(decodingError)
            }
        }

        task.resume()
    }
    
    private func getVehicleInfo(datasetId: String, vehicleId: Int, completionHandler: @escaping (String, VehicleInfo) -> ()) {
        guard let url = URL(string: "\(vehicleListURL)\(datasetId)/vehicles/\(vehicleId)") else {
            print("Unable to create URL in getVehicleInfo method")
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getVehicleInfo method received no response from the server")
                return
            }

            guard response.isSuccessful else {
                print("getVehicleInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                return
            }

            guard let data = data else {
                print("getVehicleInfo method with datasetId - \(datasetId) received no data from the server")
                return
            }
            
            do {
                let vehicleInfo = try JSONDecoder().decode(VehicleInfo.self, from: data)
                completionHandler(datasetId, vehicleInfo)
            } catch let decodingError {
                print(decodingError)
            }
        }

        task.resume()
    }
    
    private func getDealershipInfo(datasetId: String, dealerId: Int, completionHandler: @escaping (DealershipInfo) -> ()) {
        guard let url = URL(string: "\(vehicleListURL)\(datasetId)/dealers/\(dealerId)") else {
            print("Unable to create URL in getDealershipInfo method")
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDealershipInfo method received no response from the server")
                return
            }

            guard response.isSuccessful else {
                print("getDealershipInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                return
            }

            guard let data = data else {
                print("getDealershipInfo method with datasetId - \(datasetId) received no data from the server")
                return
            }
            
            do {
                let dealershipInfo = try JSONDecoder().decode(DealershipInfo.self, from: data)
                completionHandler(dealershipInfo)
            } catch let decodingError {
                print(decodingError)
            }
        }

        task.resume()
    }
}
