//
//  PersistedDataManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/12/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation

class PersistedDataManager {
    private let cacheKey: String = "persistedVehicleAndDealerData"
    private let dealershipCacheKey: String = "persistedDealershipData"
    private let vehicleCacheKey: String = "persistedVehicleData"
    
    var datasetId: String? = "mC-pYgew1wg"
    var dealershipCachePathURL: URL? {
        guard let cachesPathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return cachesPathURL.appendingPathComponent("dealerships")
    }
    
    var vehicleCachePathURL: URL? {
        guard let cachesPathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return cachesPathURL.appendingPathComponent("vehicles")
    }
    
    
    lazy var dealershipCache: [String: [DealershipInfo]] = {
        guard let dealershipCachePathURL = dealershipCachePathURL else { return [:] }
        do {
            let savedData = try Data(contentsOf: dealershipCachePathURL)
            return try JSONDecoder().decode([String: [DealershipInfo]].self, from: savedData)
        } catch {
            print(error)
        }
        
        return [String: [DealershipInfo]]()
    }()
    
    lazy var vehicleCache: [String: [VehicleInfo]] = {
        guard let vehicleCachePathURL = vehicleCachePathURL else { return [:] }
        do {
            let savedData = try Data(contentsOf: vehicleCachePathURL)
            return try JSONDecoder().decode([String: [VehicleInfo]].self, from: savedData)
        } catch {
            print(error)
        }
        
        return [String: [VehicleInfo]]()
    }()
    
    func retrieveDealershipsFromDisk() -> [DealershipInfo] {
        return dealershipCache[dealershipCacheKey] ?? []
    }
    
    func retrieveVehiclesFromDisk() -> [VehicleInfo] {
        return vehicleCache[vehicleCacheKey] ?? []
    }
    
    func storePersistedData(dealerships: [DealershipInfo], vehicles: [VehicleInfo]) {
        store(dealerships: dealerships)
        store(vehicles: vehicles)
    }
    
    func store(dealerships: [DealershipInfo]) {
        guard let cachePathURL = dealershipCachePathURL else { return }

        if (dealershipCache[dealershipCacheKey] == nil) {
            dealershipCache[dealershipCacheKey] = dealerships
        } else {
            dealershipCache.removeValue(forKey: dealershipCacheKey)
        }
        
        do {
            let jsonData = try JSONEncoder().encode(dealershipCache)
            try jsonData.write(to: cachePathURL, options: .atomic)
        } catch {
            print("Attempt to persist dealership object failed")
        }
    }
    
    func store(vehicles: [VehicleInfo]) {
        guard let cachePathURL = vehicleCachePathURL else { return }

        if (vehicleCache[vehicleCacheKey] == nil) {
            vehicleCache[vehicleCacheKey] = vehicles
        } else {
            vehicleCache.removeValue(forKey: vehicleCacheKey)
        }
        
        do {
            let jsonData = try JSONEncoder().encode(vehicleCache)
            try jsonData.write(to: cachePathURL, options: .atomic)
        } catch {
            print("Attempt to persist vehicle object failed")
        }
    }
}
