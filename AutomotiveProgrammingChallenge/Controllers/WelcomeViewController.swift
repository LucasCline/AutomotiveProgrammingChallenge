//
//  WelcomeViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var letsBeginButton: UIButton!
    private var dealerships: [DealershipInfo] = []
    
    @IBAction func letsBeginButtonTapped(_ sender: Any) {
        getAllAPIData()
        letsBeginButton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? DealershipTableViewController else {
            print("Segue destination is not DealershipTableViewController - something went wrong.")
            return
        }
        
        destinationVC.dealerships = dealerships
    }
    
    private func getAllAPIData() {
        DataProvider.getAllAPIData { (response) in
            switch response {
            case .success(let data):
                //navigate to the next screen
                self.dealerships = data.allDealerships
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "DealershipSegue", sender: self)
                }
                break
            case .failure(let error):
                print(error)
                self.letsBeginButton.isEnabled = true
                //LUCAS - Handle no data found
                //LUCAS - display error message and ask the user to try again
                break
            }
        }
    }
}
