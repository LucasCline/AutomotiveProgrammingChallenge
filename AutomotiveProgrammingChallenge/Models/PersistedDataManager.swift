//
//  PersistedDataManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/12/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation

class PersistedDataManager<T: Codable> {
    private let cacheKey: String
//    private let dealershipCacheKey: String = "persistedDealershipData"
//    private let vehicleCacheKey: String = "persistedVehicleData"
    
    init(cacheKey: String) {
        self.cacheKey = cacheKey
    }
    
    var cachePath: URL? {
        guard let cachesPathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return cachesPathURL.appendingPathComponent(cacheKey)
    }
//
//    lazy var dealershipCache: [String: [DealershipInfo]] = {
//        guard let dealershipCachePathURL = dealershipCachePathURL else { return [:] }
//        do {
//            let savedData = try Data(contentsOf: dealershipCachePathURL)
//            return try JSONDecoder().decode([String: [DealershipInfo]].self, from: savedData)
//        } catch {
//            print(error)
//        }
//
//        return [String: [DealershipInfo]]()
//    }()
//
//    lazy var vehicleCache: [String: [VehicleInfo]] = {
//
//    }()
    
    lazy var cache: [String: [T]] = {
        guard let cachePath = cachePath else { return [:] }
        do {
            let savedData = try Data(contentsOf: cachePath)
            return try JSONDecoder().decode([String: [T]].self, from: savedData)
        } catch {
            print(error)
        }
        
        return [String: [T]]()
    }()
    
    func retrieveDataFromDisk() -> [T] {
        return cache[cacheKey] ?? []
    }
//
//    func retrieveVehiclesFromDisk() -> [VehicleInfo] {
//        return vehicleCache[cac] ?? []
//    }
//
//    func storePersistedData(dealerships: [DealershipInfo], vehicles: [VehicleInfo]) {
//        store(dealerships: dealerships)
//        store(vehicles: vehicles)
//    }
//
//    func store(dealerships: [DealershipInfo]) {
//        guard let cachePathURL = dealershipCachePathURL else { return }
//
//        if (dealershipCache[dealershipCacheKey] == nil) {
//            dealershipCache[dealershipCacheKey] = dealerships
//        } else {
//            dealershipCache.removeValue(forKey: dealershipCacheKey)
//        }
//
//        do {
//            let jsonData = try JSONEncoder().encode(dealershipCache)
//            try jsonData.write(to: cachePathURL, options: .atomic)
//        } catch {
//            print("Attempt to persist dealership object failed")
//        }
//    }
//
//    func store(vehicles: [VehicleInfo]) {
//        guard let cachePath = cachePath else { return }
//
//        if (cache[cacheKey] == nil) {
//            cache[cacheKey] = vehicles as? T
//        } else {
//            vehicleCache.removeValue(forKey: vehicleCacheKey)
//        }
//
//        do {
//            let jsonData = try JSONEncoder().encode(vehicleCache)
//            try jsonData.write(to: cachePathURL, options: .atomic)
//        } catch {
//            print("Attempt to persist vehicle object failed")
//        }
//    }
    
    func store<T: Codable>(data: [T]) {
        guard let cachePath = cachePath else { return }
        
        if (cache[cacheKey] == nil) {
            cache[cacheKey] = data
        } else {
            cache.removeValue(forKey: cacheKey)
        }
        
        do {
            let jsonData = try JSONEncoder().encode(cache)
            try jsonData.write(to: cachePath, options: .atomic)
        } catch {
            print("Attempt to persist object failed")
        }
    }
//
//    func deletePersistedData() {
//        storePersistedData(dealerships: [], vehicles: [])
//    }
}
