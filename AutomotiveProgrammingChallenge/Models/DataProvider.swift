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
    //this method's completion handler contains all the dealership data
    static func getDealershipData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        getAllAPIData { (response) in
            switch response {
            case .success(let dealerships):
                completionHandler(.success(data: dealerships))
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
    
    //this method gets BOTH the dealership and the vehicle data -- it first attempts to get it from disk storage, then, if unsuccessful, tries to get it from the server
    static func getAllAPIData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        getPersistedData { (response) in
            switch response {
            case .success(let dealerships):
                if dealerships.count == 0 {
                    self.getDataFromServer(completionHandler: completionHandler)
                } else {
                    completionHandler(.success(data: dealerships))
                }
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
    
    static func getPersistedData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dealershipPDM = PersistedDataManager<DealershipInfo>(cacheKey: Constants.dealershipCacheKey)
            let dealerships = dealershipPDM.retrieveDataFromDisk()
            
            completionHandler(.success(data: dealerships))
        }
    }

    //This method will reach out to the server and attempt to get the API data
    static func getDataFromServer(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        let networkingManager = NetworkingManager()
        let dealershipPDM = PersistedDataManager<DealershipInfo>(cacheKey: "persistedDealershipData")

        networkingManager.triggerDownloadOfAllAPIData { (response) in
            switch response {
            case .success(let dealerships):
                dealershipPDM.store(data: dealerships)
                completionHandler(.success(data: dealerships))
                break
            case .failure(let error):
                completionHandler(.failure(error: error))
                break
            }
        }
    }
}
