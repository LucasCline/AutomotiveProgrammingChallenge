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
    
    var errorDescription: String? {
        switch self {
        case .noResponse:
            return "No response received from the server."
        case .noData:
            return "No data found in the request."
        case .notSuccessful:
            return "Request not successful."
        case .couldNotCreateURL:
            return "Unable to create URL."
        }
    }
}

struct NetworkingManager {
    func triggerDownloadOfAllAPIData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        triggerDatasetRequest(completionHandler: completionHandler)
    }
    
    private func triggerDatasetRequest(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        getDatasetId { (response) in
            switch response {
            case .success(let datasetId):
                self.triggerVehicleListRequestWith(datasetId: datasetId, completionHandler: completionHandler)
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
        
    private func triggerVehicleListRequestWith(datasetId: String, completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
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
        
    private func triggerVehicleInfoRequestsWith(datasetId: String, vehicleIds: [Int], completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        let dispatchGroup = DispatchGroup()
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
                    dispatchGroup.leave()
                    break
                case .failure(let error):
                    print(error)
                    dispatchGroup.leave()
                    break
                }
            }
        }
        
        //This block gets executed after all of the vehicle info has been saved
        dispatchGroup.notify(queue: .global()) {
            self.triggerDealershipInfoRequestsWith(datasetId: datasetId, dealerVehicleDictionary: dealerVehicleDictionary) { (response) in
                switch response {
                case .success(let allDealershipData):
                    completionHandler(.success(data: allDealershipData))
                    break
                case .failure(error: let error):
                    completionHandler(.failure(error: error))
                    break
                }
            }
        }
    }
    
    private func triggerDealershipInfoRequestsWith(datasetId: String, dealerVehicleDictionary: [Int: [VehicleInfo]], completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
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
        
        //This block gets executed after all of the dealership info has been saved
        dispatchGroup.notify(queue: .global()) {
            completionHandler(.success(data: allDealershipData))
        }
    }

    private func getDatasetId(completionHandler: @escaping (NetworkResponse<String>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)datasetId") else {
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }

            guard response.isSuccessful else {
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                completionHandler(.failure(error: NetworkError.noData))
                return
            }

            do {
                let dataset = try JSONDecoder().decode(Dataset.self, from: data)
                completionHandler(.success(data: dataset.id))
            } catch let decodingError {
                completionHandler(.failure(error: decodingError))
            }
        }

        task.resume()
    }
    
    private func getVehicleList(datasetId: String, completionHandler: @escaping (NetworkResponse<(dataset: String, vehicleIds: [Int])>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)\(datasetId)/vehicles") else {
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }
            
            guard response.isSuccessful else {
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                completionHandler(.failure(error: NetworkError.noData))
                return
            }

            do {
                let vehicleList = try JSONDecoder().decode(VehicleList.self, from: data)
                completionHandler(.success(data: (datasetId, vehicleList.ids)))
            } catch let decodingError {
                completionHandler(.failure(error:decodingError))
            }
        }

        task.resume()
    }
    
    private func getVehicleInfo(datasetId: String, vehicleId: Int, completionHandler: @escaping (NetworkResponse<(datasetId: String, vehicleInfo: VehicleInfo)>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)\(datasetId)/vehicles/\(vehicleId)") else {
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }

            guard response.isSuccessful else {
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                completionHandler(.failure(error: NetworkError.noData))
                return
            }
            
            do {
                let vehicleInfo = try JSONDecoder().decode(VehicleInfo.self, from: data)
                completionHandler(.success(data: (datasetId: datasetId, vehicleInfo: vehicleInfo)))
            } catch let decodingError {
                completionHandler(.failure(error: decodingError))
            }
        }

        task.resume()
    }
    
    private func getDealershipInfo(datasetId: String, dealerId: Int, completionHandler: @escaping (NetworkResponse<DealershipInfo>) -> ()) {
        guard let url = URL(string: "\(rootAPIURL)\(datasetId)/dealers/\(dealerId)") else {
            completionHandler(.failure(error: NetworkError.couldNotCreateURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let response = response else {
                completionHandler(.failure(error: NetworkError.noResponse))
                return
            }

            guard response.isSuccessful else {
                completionHandler(.failure(error: NetworkError.notSuccessful))
                return
            }

            guard let data = data else {
                completionHandler(.failure(error: NetworkError.noData))
                return
            }
            
            do {
                let dealershipInfo = try JSONDecoder().decode(DealershipInfo.self, from: data)
                completionHandler(.success(data: dealershipInfo))
            } catch let decodingError {
                completionHandler(.failure(error: decodingError))
            }
        }

        task.resume()
    }
}
