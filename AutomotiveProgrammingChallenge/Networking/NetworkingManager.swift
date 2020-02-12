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

enum NetworkResponse<T: Any> {
    case failure(error: Error)
    case success(data: T)
}

struct NetworkingManager {
    //call this something like triggerDownloadOfDealershipAndVehicleData()
    func downloadAndSaveAllAPIData(completionHandler: @escaping () -> ()) {
        triggerDatasetRequest {
            print("finished")
            completionHandler()
        }
    }
    
    func triggerDatasetRequest(completionHandler: @escaping () -> ()) {
        getDatasetId { (response) in
            switch response {
            case .success(let datasetId):
                print(datasetId)
                self.triggerVehicleListRequestWith(datasetId: datasetId, completionHandler: completionHandler)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
        
    func triggerVehicleListRequestWith(datasetId: String, completionHandler: @escaping () -> ()) {
        getVehicleList(datasetId: datasetId) { (response) in
            switch response {
            case .success(let data):
                self.triggerVehicleInfoRequestsWith(datasetId: data.dataset, vehicleIds: data.vehicleIds, completionHandler: completionHandler)
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
        
    func triggerVehicleInfoRequestsWith(datasetId: String, vehicleIds: [Int], completionHandler: @escaping () -> ()) {
        let dispatchGroup = DispatchGroup()
        var dealerIds: Set<Int> = []
        vehicleIds.forEach { (vehicleId) in
            dispatchGroup.enter()
            self.getVehicleInfo(datasetId: datasetId, vehicleId: vehicleId) { (response) in
                switch response {
                case .success(let data):
                    dealerIds.insert(data.vehicleInfo.dealerId)
                    CoreDataManager.shared.saveVehicleInfo(data.vehicleInfo) {
                        dispatchGroup.leave()
                    }
                    break
                case .failure(let error):
                    print(error)
                    dispatchGroup.leave()
                    break
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
            self.getDealershipInfo(datasetId: datasetId, dealerId: dealershipId) { (response) in
                switch response {
                case .success(let dealershipInfo):
                    CoreDataManager.shared.saveDealershipInfo(dealershipInfo) {
                        dispatchGroup.leave()
                    }
                    break
                case .failure(let error):
                    print(error)
                    dispatchGroup.leave()
                    break
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            print("All dealership data saved")
            completionHandler()
        }
    }

    private func getDatasetId(completionHandler: @escaping (NetworkResponse<String>) -> ()) {
        guard let url = URL(string: datasetIdURL) else {
            print("Unable to create URL in getDatasetId method")
            completionHandler(.failure(error:"Unable to create URL in getDatasetId method"))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDatasetId method received no response from the server")
                completionHandler(.failure(error: "getDatasetId method received no response from the server"))
                return
            }

            guard response.isSuccessful else {
                print("getDatasetId method was unsuccessful with response - \(response)")
                completionHandler(.failure(error: "getDatasetId method was unsuccessful with response - \(response)"))
                return
            }

            guard let data = data else {
                print("getDatasetId method received no data from the server")
                completionHandler(.failure(error: "getDatasetId method received no data from the server"))
                return
            }

            do {
                let dataset = try JSONDecoder().decode(Dataset.self, from: data)
                completionHandler(.success(data: dataset.id))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: "failed to decode dataset with decoding error - \(decodingError)"))
            }
        }

        task.resume()
    }
    
    private func getVehicleList(datasetId: String, completionHandler: @escaping (NetworkResponse<(dataset: String, vehicleIds: [Int])>) -> ()) {
        guard let url = URL(string: "\(vehicleListURL)\(datasetId)/vehicles") else {
            print("Unable to create URL in getVehicleList method")
            completionHandler(.failure(error: "Unable to create URL in getVehicleList method"))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getVehicleList method received no response from the server")
                completionHandler(.failure(error: "getVehicleList method received no response from the server"))
                return
            }
            
            guard response.isSuccessful else {
                print("getVehicleList method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                completionHandler(.failure(error: "getVehicleList method with datasetId - \(datasetId) was unsuccessful with response - \(response)"))
                return
            }

            guard let data = data else {
                print("getVehicleList method with datasetId - \(datasetId) received no data from the server")
                completionHandler(.failure(error: "getVehicleList method with datasetId - \(datasetId) received no data from the server"))
                return
            }

            do {
                let vehicleList = try JSONDecoder().decode(VehicleList.self, from: data)
                completionHandler(.success(data: (datasetId, vehicleList.ids)))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: "failed to decode dataset with decoding error - \(decodingError)"))
            }
        }

        task.resume()
    }
    
    private func getVehicleInfo(datasetId: String, vehicleId: Int, completionHandler: @escaping (NetworkResponse<(datasetId: String, vehicleInfo: VehicleInfo)>) -> ()) {
        guard let url = URL(string: "\(vehicleListURL)\(datasetId)/vehicles/\(vehicleId)") else {
            print("Unable to create URL in getVehicleInfo method")
            completionHandler(.failure(error: "Unable to create URL in getVehicleInfo method"))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getVehicleInfo method received no response from the server")
                completionHandler(.failure(error: "getVehicleInfo method received no response from the server"))
                return
            }

            guard response.isSuccessful else {
                print("getVehicleInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                completionHandler(.failure(error: "getVehicleInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)"))
                return
            }

            guard let data = data else {
                print("getVehicleInfo method with datasetId - \(datasetId) received no data from the server")
                completionHandler(.failure(error: "getVehicleInfo method with datasetId - \(datasetId) received no data from the server"))
                return
            }
            
            do {
                let vehicleInfo = try JSONDecoder().decode(VehicleInfo.self, from: data)
                completionHandler(.success(data: (datasetId: datasetId, vehicleInfo: vehicleInfo)))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: "failed to decode dataset with decoding error - \(decodingError)"))
            }
        }

        task.resume()
    }
    
    private func getDealershipInfo(datasetId: String, dealerId: Int, completionHandler: @escaping (NetworkResponse<DealershipInfo>) -> ()) {
        guard let url = URL(string: "\(vehicleListURL)\(datasetId)/dealers/\(dealerId)") else {
            print("Unable to create URL in getDealershipInfo method")
            completionHandler(.failure(error: "Unable to create URL in getDealershipInfo method"))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDealershipInfo method received no response from the server")
                completionHandler(.failure(error: "getDealershipInfo method received no response from the server"))
                return
            }

            guard response.isSuccessful else {
                print("getDealershipInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                completionHandler(.failure(error: "getDealershipInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)"))
                return
            }

            guard let data = data else {
                print("getDealershipInfo method with datasetId - \(datasetId) received no data from the server")
                completionHandler(.failure(error: "getDealershipInfo method with datasetId - \(datasetId) received no data from the server"))
                return
            }
            
            do {
                let dealershipInfo = try JSONDecoder().decode(DealershipInfo.self, from: data)
                completionHandler(.success(data: dealershipInfo))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: "failed to decode dataset with decoding error - \(decodingError)"))
            }
        }

        task.resume()
    }
}

//LUCAS - dont leave this here
extension String: Error { }
