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
    var dealerships: [DealershipInfo] = []
    
    private var dealershipForSegue: DealershipInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dealershipTableView.delegate = self
        dealershipTableView.dataSource = self
        
        //LUCAS - should i try to grab this out of storage if its 0 first? right now its being passed in from the previous VC. maybe it gets lost in memory or something if something weird happens with the phone? so far havent been able to produce that issue
        if dealerships.count == 0 {
            DispatchQueue.main.async {
                self.displayAlertForNoDealershipDataFound()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? VehicleTableViewController else {
            return
        }
        
        destinationVC.vehicles = dealershipForSegue?.vehicles ?? []
    }
    
    private func displayAlertForNoDealershipDataFound() {
        let alert = UIAlertController(title: "Dealership Data Not Found", message: "There was no dealership data found for the given Dataset ID.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

extension DealershipTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dealershipForSegue = dealerships[indexPath.row]
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
