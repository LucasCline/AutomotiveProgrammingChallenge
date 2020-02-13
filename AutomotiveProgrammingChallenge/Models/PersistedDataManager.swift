//
//  PersistedDataManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/12/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation

enum Constants {
    static let dealershipCacheKey = "persistedDealershipData"
    static let vehicleCacheKey = "persistedVehicleData"
}

class PersistedDataManager<T: Codable> {
    private let cacheKey: String

    init(cacheKey: String) {
        self.cacheKey = cacheKey
    }

    func retrieveDataFromDisk() -> [T] {
        return cache[cacheKey] ?? []
    }

    func store(data: [T]) {
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

    //LUCAS - Debug Only
    func deletePersistedData() {
        store(data: [])
    }
    
    private var cachePath: URL? {
        guard let cachesPathURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return cachesPathURL.appendingPathComponent(cacheKey)
    }
    
    private lazy var cache: [String: [T]] = {
        guard let cachePath = cachePath else { return [:] }
        do {
            let savedData = try Data(contentsOf: cachePath)
            return try JSONDecoder().decode([String: [T]].self, from: savedData)
        } catch {
            print(error)
        }
        
        return [String: [T]]()
    }()
}
