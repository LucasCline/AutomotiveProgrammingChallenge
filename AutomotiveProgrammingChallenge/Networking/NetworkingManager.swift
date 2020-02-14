//
//  NetworkingManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

private let rootAPIURL = "http://api.coxauto-interview.com/api/"

enum NetworkResponse<T: Any> {
    case failure(error: Error)
    case success(data: T)
}

enum NetworkError: LocalizedError {
    case noResponse
    case noData
    case notSuccessful
    case couldNotCreateURL
    
    //LUCAS - these are supposed to be for displaying to the user? better way to do this? 
    var errorDescription: String? {
        switch self {
        case .noResponse:
            return NSLocalizedString("No response received from the server.", comment: "")
        case .noData:
            return NSLocalizedString("No data found in the request.", comment: "")
        case .notSuccessful:
            return NSLocalizedString("Request not successful.", comment: "")
        case .couldNotCreateURL:
            return NSLocalizedString("Unable to create URL.", comment: "")
        }
    }
}

typealias AllAPIDataResponse = (NetworkResponse<(allVehicles: [VehicleInfo], allDealerships: [DealershipInfo])>) -> ()

struct NetworkingManager {
    //call this something like triggerDownloadOfDealershipAndVehicleData()
    func triggerDownloadOfAllAPIData(completionHandler: @escaping AllAPIDataResponse) {
        triggerDatasetRequest(completionHandler: completionHandler)
    }
    
    func triggerDatasetRequest(completionHandler: @escaping AllAPIDataResponse) {
        getDatasetId { (response) in
            switch response {
            case .success(let datasetId):
                print(datasetId)
                self.triggerVehicleListRequestWith(datasetId: datasetId, completionHandler: completionHandler)
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
        
    func triggerVehicleListRequestWith(datasetId: String, completionHandler: @escaping AllAPIDataResponse) {
        getVehicleList(datasetId: datasetId) { (response) in
            switch response {
            case .success(let data):
                self.triggerVehicleInfoRequestsWith(datasetId: data.dataset, vehicleIds: data.vehicleIds, completionHandler: completionHandler)
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
        
    func triggerVehicleInfoRequestsWith(datasetId: String, vehicleIds: [Int], completionHandler: @escaping AllAPIDataResponse) {
        let dispatchGroup = DispatchGroup()
        var allVehicleData: [VehicleInfo] = []
        var dealerVehicleDictionary: [Int: [VehicleInfo]] = [:]
        vehicleIds.forEach { (vehicleId) in
            dispatchGroup.enter()
            self.getVehicleInfo(datasetId: datasetId, vehicleId: vehicleId) { (response) in
                switch response {
                case .success(let data):
                    if dealerVehicleDictionary[data.vehicleInfo.dealerId] == nil {
                        dealerVehicleDictionary[data.vehicleInfo.dealerId] = []
                    }
                    dealerVehicleDictionary[data.vehicleInfo.dealerId]?.append(data.vehicleInfo)
                    allVehicleData.append(data.vehicleInfo)
                    dispatchGroup.leave()
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
            self.triggerDealershipInfoRequestsWith(datasetId: datasetId, dealerVehicleDictionary: dealerVehicleDictionary) { (response) in
                switch response {
                case .success(let allDealershipData):
                    completionHandler(.success(data: (allVehicleData, allDealershipData)))
                    break
                case .failure(error: let error):
                    completionHandler(.failure(error: error))
                    break
                }
            }
        }
    }
    
    //in the notify group - we pass it back
    func triggerDealershipInfoRequestsWith(datasetId: String, dealerVehicleDictionary: [Int: [VehicleInfo]], completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        let dispatchGroup = DispatchGroup()
        var allDealershipData: [DealershipInfo] = []
        
        dealerVehicleDictionary.keys.forEach { (dealershipId) in
            dispatchGroup.enter()
            self.getDealershipInfo(datasetId: datasetId, dealerId: dealershipId) { (response) in
                switch response {
                case .success(var dealershipInfo):
                    dealershipInfo.vehicles = dealerVehicleDictionary[dealershipInfo.id] ?? []
                    allDealershipData.append(dealershipInfo)
                    dispatchGroup.leave()
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
            completionHandler(.success(data: allDealershipData))
        }
    }

    private func getDatasetId(completionHandler: @escaping (NetworkResponse<String>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)datasetId") else {
            print("Unable to create URL in getDatasetId method")
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDatasetId method received no response from the server")
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }

            guard response.isSuccessful else {
                print("getDatasetId method was unsuccessful with response - \(response)")
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                print("getDatasetId method received no data from the server")
                completionHandler(.failure(error: NetworkError.noData))
                return
            }

            do {
                let dataset = try JSONDecoder().decode(Dataset.self, from: data)
                completionHandler(.success(data: dataset.id))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: decodingError))
            }
        }

        task.resume()
    }
    
    private func getVehicleList(datasetId: String, completionHandler: @escaping (NetworkResponse<(dataset: String, vehicleIds: [Int])>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)\(datasetId)/vehicles") else {
            print("Unable to create URL in getVehicleList method")
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getVehicleList method received no response from the server")
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }
            
            guard response.isSuccessful else {
                print("getVehicleList method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                print("getVehicleList method with datasetId - \(datasetId) received no data from the server")
                completionHandler(.failure(error: NetworkError.noData))
                return
            }

            do {
                let vehicleList = try JSONDecoder().decode(VehicleList.self, from: data)
                completionHandler(.success(data: (datasetId, vehicleList.ids)))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error:decodingError))
            }
        }

        task.resume()
    }
    
    private func getVehicleInfo(datasetId: String, vehicleId: Int, completionHandler: @escaping (NetworkResponse<(datasetId: String, vehicleInfo: VehicleInfo)>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)\(datasetId)/vehicles/\(vehicleId)") else {
            print("Unable to create URL in getVehicleInfo method")
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getVehicleInfo method received no response from the server")
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }

            guard response.isSuccessful else {
                print("getVehicleInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                print("getVehicleInfo method with datasetId - \(datasetId) received no data from the server")
                completionHandler(.failure(error: NetworkError.noData))
                return
            }
            
            do {
                let vehicleInfo = try JSONDecoder().decode(VehicleInfo.self, from: data)
                completionHandler(.success(data: (datasetId: datasetId, vehicleInfo: vehicleInfo)))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: decodingError))
            }
        }

        task.resume()
    }
    
    private func getDealershipInfo(datasetId: String, dealerId: Int, completionHandler: @escaping (NetworkResponse<DealershipInfo>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)\(datasetId)/dealers/\(dealerId)") else {
            print("Unable to create URL in getDealershipInfo method")
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                print("getDealershipInfo method received no response from the server")
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }

            guard response.isSuccessful else {
                print("getDealershipInfo method with datasetId - \(datasetId) was unsuccessful with response - \(response)")
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                print("getDealershipInfo method with datasetId - \(datasetId) received no data from the server")
                completionHandler(.failure(error: NetworkError.noData))
                return
            }
            
            do {
                let dealershipInfo = try JSONDecoder().decode(DealershipInfo.self, from: data)
                completionHandler(.success(data: dealershipInfo))
            } catch let decodingError {
                print(decodingError)
                completionHandler(.failure(error: decodingError))
            }
        }

        task.resume()
    }
}
