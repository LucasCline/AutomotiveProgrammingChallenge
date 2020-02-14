//
//  DataProvider.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/12/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation

enum DataProviderError: LocalizedError {
    case noDataFoundOnDisk
    
    var errorDescription: String? {
        switch self {
        case .noDataFoundOnDisk:
            return NSLocalizedString("No data found persisted on disk", comment: "")//"No data found persisted on disk"
        }
    }
}

struct DataProvider {
    //this method's completion handler contains all the vehicle data
    static func getVehicleData(completionHandler: @escaping (NetworkResponse<[VehicleInfo]>) -> ()) {
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
    
    //this method's completion handler contains all the dealership data
    static func getDealershipData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
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
    
    //this method gets BOTH the dealership and the vehicle data -- it first attempts to get it from disk storage, then, if unsuccessful, tries to get it from the server
    static func getAllAPIData(completionHandler: @escaping AllAPIDataResponse) {
        getPersistedData { (response) in
            switch response {
            case .success(let data):
                if data.allDealerships.count == 0 {
                    self.getDataFromServer(completionHandler: completionHandler)
                } else {
                    print("persisted data found - no need to make network call")
                    completionHandler(.success(data: data))
                }
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
    
    //LUCAS - REMOVE 2nd PDM - fix all responses to be just network
    static func getPersistedData(completionHandler: @escaping AllAPIDataResponse) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dealershipPDM = PersistedDataManager<DealershipInfo>(cacheKey: Constants.dealershipCacheKey)
            let vehiclePDM = PersistedDataManager<VehicleInfo>(cacheKey: Constants.vehicleCacheKey)
            
            let dealerships = dealershipPDM.retrieveDataFromDisk()
            let vehicles = vehiclePDM.retrieveDataFromDisk()
            
            completionHandler(.success(data: (allVehicles: vehicles, allDealerships: dealerships)))
        }
    }

    //This method will reach out to the server and attempt to get the API data
    static func getDataFromServer(completionHandler: @escaping AllAPIDataResponse) {
        let networkingManager = NetworkingManager()
        let dealershipPDM = PersistedDataManager<DealershipInfo>(cacheKey: "persistedDealershipData")

        networkingManager.triggerDownloadOfAllAPIData { (response) in
            switch response {
            case .success(let data):
                dealershipPDM.store(data: data.allDealerships)
                completionHandler(.success(data: data))
                break
            case .failure(let error):
                print(error)
                completionHandler(.failure(error: error))
                break
            }
        }
    }
}
