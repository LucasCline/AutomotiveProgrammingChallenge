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
            return "No data found persisted on disk"
        }
    }
}

struct DataProvider {
    //This method attempts to retrieve API data from persistence. If unsuccessful, it makes a request to the server
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
    
    static private func getPersistedData(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            let dealershipPDM = PersistedDataManager<DealershipInfo>(cacheKey: Constants.dealershipCacheKey)
            let dealerships = dealershipPDM.retrieveDataFromDisk()
            
            completionHandler(.success(data: dealerships))
        }
    }

    static private func getDataFromServer(completionHandler: @escaping (NetworkResponse<[DealershipInfo]>) -> ()) {
        let networkingManager = NetworkingManager()
        let dealershipPDM = PersistedDataManager<DealershipInfo>(cacheKey: Constants.dealershipCacheKey)

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
