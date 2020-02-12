//
//  VehicleInfo.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import Foundation
import CoreData

struct Dataset: Codable {
    var id: String
    enum CodingKeys: String, CodingKey {
        case id = "datasetId"
    }
}

struct VehicleList: Codable {
    var ids: [Int]
    enum CodingKeys: String, CodingKey {
        case ids = "vehicleIds"
    }
}

struct VehicleInfo: Codable {
    var dealerId: Int
    var make: String
    var model: String
    var vehicleId: Int
    var year: Int
}

struct DealershipInfo: Codable {
    var id: Int
    var name: String
    enum CodingKeys: String, CodingKey {
        case id = "dealerId"
        case name
    }
}
