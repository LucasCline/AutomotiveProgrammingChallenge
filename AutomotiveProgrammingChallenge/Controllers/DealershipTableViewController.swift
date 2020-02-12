//
//  DealershipTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit
import CoreData //for now

class DealershipTableViewController: UIViewController {
    @IBOutlet weak var dealershipTableView: UITableView!
    private var dealerIdForSegue: Int?
    private var dealerIds: Set<Int> = []
    
    private var newDealerships: [DealershipInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dealershipTableView.delegate = self
        dealershipTableView.dataSource = self
    
        fetchDealershipData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? VehicleTableViewController else {
            return
        }
        
        destinationVC.dealerId = dealerIdForSegue
    }
    
    private func fetchDealershipData() {
        DataProvider().getDealershipData { (response) in
            switch response {
            case .success(let dealerships):
                self.newDealerships = dealerships
                DispatchQueue.main.async {
                    self.dealershipTableView.reloadData()
                }
                //LUCAS - persist here
                //DataPersister.persist(data) //since we fetch from the server go ahead and save everything
                break
            case .failure(let error):
                print(error)
                //LUCAS - Handle no data found
                break
            }
        }
        
//        CoreDataManager.shared.fetchEntity(entityName: "Dealership") { (dealerships) in
//            if dealerships.count == 0 {
//                //LUCAS - do work to display an empty table - this is a valid flow/server/data issue - no dealers for given dataset
//                //NetworkingManager().downloadAndSaveAllAPIData()
//            } else {
//                self.dealerships = dealerships
//                DispatchQueue.main.async {
//                    self.dealershipTableView.reloadData()
//                }
//            }
//        }
    }
}

extension DealershipTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dealerId = newDealerships[indexPath.row].id
        //let dealerId = dealerships[indexPath.row].value(forKey: "id") as? Int
        dealerIdForSegue = dealerId
        performSegue(withIdentifier: "VehicleSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DealershipTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newDealerships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealershipCell", for: indexPath) as? DealershipTableViewCell else {
            print("Unable to cast the table view cell to a DealershipCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }
        
        let dealership = newDealerships[indexPath.row]
//
//        guard let name = dealership.value(forKeyPath: "name") as? String,
//            let id = dealership.value(forKeyPath: "id") as? Int else {
//                print("Unable to retrieve dealership values for cell - returning a blank UITableViewCell")
//                return UITableViewCell()
//        }
//
//        cell.dealershipName.text = name
//        cell.dealershipId.text = "ID: \(id))"
        
        cell.dealershipName.text = dealership.name
        cell.dealershipId.text = "ID: \(dealership.id)"
        
        return cell
    }
}
