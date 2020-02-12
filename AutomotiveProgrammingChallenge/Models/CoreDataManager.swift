//
//  CoreDataManager.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/9/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    //LUCAS - Prevent this from being changed
    var persistentContainer: NSPersistentContainer?

    func fetchEntity(entityName: String, completionHandler: @escaping ([NSManagedObject]) -> ()) {
        guard let managedContext = persistentContainer?.viewContext else { fatalError() }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        
        do {
            let fetchedEntities = try managedContext.fetch(fetchRequest)
            completionHandler(fetchedEntities)
        } catch let error as NSError {
            print("Could not fetch entity - \(entityName) with error - \(error), \(error.userInfo)")
        }
    }
    
    func saveDealershipInfo(_ dealershipInfo: DealershipInfo, completionHandler: @escaping() -> ()) {
        guard let managedContext = persistentContainer?.viewContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Dealership", in: managedContext) else { fatalError() }
        let dealership = NSManagedObject(entity: entity, insertInto: managedContext)
        
        dealership.setValue(dealershipInfo.id, forKeyPath: "id")
        dealership.setValue(dealershipInfo.name, forKey: "name")
        
        do {
            try managedContext.save()
            completionHandler()
        } catch let error as NSError {
            print("Could not save core data object dealership with errors - \(error), \(error.userInfo)")
            completionHandler()
        }
    }
    
    func saveVehicleInfo(_ vehicleInfo: VehicleInfo, completionHandler: @escaping() -> ()) {
        guard let managedContext = persistentContainer?.viewContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Vehicle", in: managedContext) else { fatalError() }
        let vehicle = NSManagedObject(entity: entity, insertInto: managedContext)
        
        vehicle.setValue(vehicleInfo.dealerId, forKeyPath: "dealerId")
        vehicle.setValue(vehicleInfo.make, forKey: "make")
        vehicle.setValue(vehicleInfo.model, forKey: "model")
        vehicle.setValue(vehicleInfo.vehicleId, forKey: "vehicleId")
        vehicle.setValue(vehicleInfo.year, forKey: "year")
        
        do {
            try managedContext.save()
            completionHandler()
        } catch let error as NSError {
            print("Could not save core data object vehicle with errors - \(error), \(error.userInfo)")
        }
    }
    
    //LUCAS - For Debug Only
    func deleteAllCoreData() {
        deleteCoreData {
            print("deleted dealerships")
        }
        deleteCoreData2 {
            print("deleted vehicles")
        }
    }
    
    //debugging only - only deletes dealership data
    private func deleteCoreData(completionHandler: @escaping () -> ()) {
        guard let managedContext = persistentContainer?.viewContext else { fatalError() }
        let fetchRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSManagedObject>(entityName: "Dealership") as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try managedContext.execute(fetchRequest)
            completionHandler()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    //debugging only - only deletes dealership data
    private func deleteCoreData2(completionHandler: @escaping () -> ()) {
        guard let managedContext = persistentContainer?.viewContext else { fatalError() }
        let fetchRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSManagedObject>(entityName: "Vehicle") as! NSFetchRequest<NSFetchRequestResult>)

        do {
            try managedContext.execute(fetchRequest)
            completionHandler()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
