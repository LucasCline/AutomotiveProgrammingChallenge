//
//  DataProvider.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/12/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation

struct DataProvider {
    //this method gets all the vehicle data
    func getVehicleData(completionHandler: @escaping (NetworkResponse<[VehicleInfo]>) -> ()) {
        getAllAPIData { (response) in
            switch response {
            case .success(let data):
                completionHandler(.success(data: data.allVehicles))
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
    
    //this method gets all the dealership data
    func getDealershipData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        getAllAPIData { (response) in
            switch response {
            case .success(let data):
                completionHandler(.success(data: data.allDealerships))
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
    
    //this method gets BOTH the dealership and the vehicle data
    private func getAllAPIData(completionHandler: @escaping AllAPIDataResponse) {
        getPersistedData { (response) in
            switch response {
            case .success(let data):
                completionHandler(.success(data: data))
                print("persised data found - no need to make network call") //LUCAS - DEbug statement
                break
            case .failure(let error):
                print(error)
                print("No data found  persisted - need to make network call") //LUCAS - DEbug statement
                self.getDataFromServer(completionHandler: completionHandler)
                break
            }
        }
    }
    
    //LUCAS - This method will reach out to the disk storage similar to how getDataFromAPI uses networking manager
    func getPersistedData(completionHandler: @escaping AllAPIDataResponse) {
        let persistedDataManager = PersistedDataManager()
        let dealerships = persistedDataManager.retrieveDealershipsFromDisk()
        let vehicles = persistedDataManager.retrieveVehiclesFromDisk()
        
        //LUCAS - do the same thing for vehicles?
        guard dealerships.count > 0 else {
            completionHandler(.failure(error: "No dealership data found persisted on disk"))
            return
        }
        
        guard vehicles.count > 0 else {
            completionHandler(.failure(error: "No vehicle data found persisted on disk"))
            return
        }
        
        completionHandler(.success(data: (allVehicles: vehicles, allDealerships: dealerships)))
    }
    
    //this method will reach out to the server and attempt to get the API data
    func getDataFromServer(completionHandler: @escaping AllAPIDataResponse) {
        let networkingManager = NetworkingManager()
        let persistedDataManager = PersistedDataManager()
        var dataset: String? = "mC-pYgew1wg" //LUCAS - need to decide what to do with dataset//maybe do a fake check for an expiration or something? Give it a timer to reset, but never actually let it reset
        
        //if the dataset already exists - we skip getting a new dataset and just trigger the vehicle list again, otherwise download all the data (dataset -> vehicle list -> [vehicle info] -> [dealer info])
        if let dataset = dataset {
            networkingManager.triggerVehicleListRequestWith(datasetId: dataset) { (response) in
                switch response {
                case .success(let data):
                    persistedDataManager.storePersistedData(dealerships: data.allDealerships, vehicles: data.allVehicles)
                    completionHandler(.success(data: data))
                    break
                case .failure(let error):
                    completionHandler(.failure(error: error))
                }
            }
        } else {
            networkingManager.triggerDownloadOfAllAPIData { (response) in
                switch response {
                case .success(let data):
                    persistedDataManager.storePersistedData(dealerships: data.allDealerships, vehicles: data.allVehicles)
                    completionHandler(.success(data: data))
                    print(data)
                    break
                case .failure(let error):
                    print(error)
                    completionHandler(.failure(error: error))
                    break
                }
            }
        }
    }
}
