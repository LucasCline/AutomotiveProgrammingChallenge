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
        getAPIData { (response) in
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
        getAPIData { (response) in
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
    private func getAPIData(completionHandler: @escaping AllAPIDataResponse) {
        getPersistedData { (response) in
            switch response {
            case .success(let data):
                completionHandler(.success(data: data))
                break
            case .failure(let error):
                print(error)
                self.getDataFromAPI(completionHandler: completionHandler)
                break
            }
        }
    }
    
    //LUCAS - This method will reach out to the disk storage similar to how getDataFromAPI uses networking manager
    func getPersistedData(completionHandler: @escaping AllAPIDataResponse) {
//        let persistentDataManager = PersistentDataManager()
//
//        persistentDataManager.retrievePersistedAPIData() { response in
//            switch response {
//            case .success(let data):
//                completionHandler(.success(data: data))
//                break
//            case .failure(let error):
//                completionHandler(.failure(error: error))
//                break
//            }
//        }
//
        completionHandler(.failure(error: "No data found persisted on disk"))
    }
    
    //this method will reach out to the server and attempt to get the API data
    func getDataFromAPI(completionHandler: @escaping AllAPIDataResponse) {
        let networkingManager = NetworkingManager()
        var dataset: String? = "mC-pYgew1wg"
        
        //if the dataset already exists - we skip getting a new dataset and just trigger the vehicle list again, otherwise download all the data (dataset -> vehicle list -> [vehicle info] -> [dealer info])
        if let dataset = dataset {
            networkingManager.triggerVehicleListRequestWith(datasetId: dataset) { (response) in
                switch response {
                case .success(let data):
                    completionHandler(.success(data: data))
                    break
                case .failure(let error):
                    completionHandler(.failure(error: error))
                }
            }
        } else {
            networkingManager.downloadAndSaveAllAPIData { (response) in
                switch response {
                case .success(let data):
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
