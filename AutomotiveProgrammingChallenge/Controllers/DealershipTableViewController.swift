//
//  DealershipTableViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class DealershipTableViewController: UIViewController {
    @IBOutlet weak var dealershipTableView: UITableView!
    private var dealerIdForSegue: Int?
    private var dealerIds: Set<Int> = []
    
    var dealerships: [DealershipInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dealershipTableView.delegate = self
        dealershipTableView.dataSource = self
    
        fetchDealershipData()
    }
    
    private func fetchDealershipData() {
        DataProvider().getDealershipData { (response) in
            switch response {
            case .success(let dealerships):
                self.dealerships = dealerships
                DispatchQueue.main.async {
                    self.dealershipTableView.reloadData()
                }
                break
            case .failure(let error):
                print(error)
                //LUCAS - Handle no data found
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? VehicleTableViewController else {
            return
        }
        
        destinationVC.dealerId = dealerIdForSegue
    }
}

extension DealershipTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dealerId = dealerships[indexPath.row].id
        dealerIdForSegue = dealerId
        performSegue(withIdentifier: "VehicleSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DealershipTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dealerships.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealershipCell", for: indexPath) as? DealershipTableViewCell else {
            print("Unable to cast the table view cell to a DealershipCell -- returning a blank UITableViewCell")
            return UITableViewCell()
        }
        
        let dealership = dealerships[indexPath.row]

        cell.dealershipName.text = dealership.name
        cell.dealershipId.text = "ID: \(dealership.id)"
        
        return cell
    }
}
