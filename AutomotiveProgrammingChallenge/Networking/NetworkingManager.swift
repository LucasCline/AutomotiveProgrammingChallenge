//
//  NetworkingManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation
let datasetIdURL = "http://api.coxauto-interview.com/api/datasetId"
let vehicleListURL = "http://api.coxauto-interview.com/api/"
let vehicleInfoURL = "http://api.coxauto-interview.com/api/"
let dealershipInfoURL = "http://api.coxauto-interview.com/api/adfdasfasf/dealers/123213123"


struct NetworkingManager {
    func getDatasetId(completionHandler: @escaping (String) -> ()) {
        guard let url = URL(string: datasetIdURL) else {
            print("Unable to create URL in getDatasetId method")
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDatasetId method received no response from the server")
                return
            }
            
            guard response.isSuccessful else {
                print("getDatasetId method was unsuccessful with response - \(response)")
                return
            }

            guard let data = data else {
                print("getDatasetId method received no data from the server")
                return
            }

            do {
                let dataset = try JSONDecoder().decode(Dataset.self, from: data)
                completionHandler(dataset.id)
            } catch let decodingError {
                print(decodingError)
            }
        }

        task.resume()
    }
    
    func getVehicleList(datasetId: String, completionHandler: @escaping (String, [Int]) -> ()) {
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
    
    func getVehicleInfo(datasetId: String, vehicleId: Int, completionHandler: @escaping (String, VehicleInfo) -> ()) {
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
    
    func getDealershipInfo(datasetId: String, dealerId: Int, completionHandler: @escaping (String, DealershipInfo) -> ()) {
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
                completionHandler(datasetId, dealershipInfo)
            } catch let decodingError {
                print(decodingError)
            }
        }

        task.resume()
    }
}
