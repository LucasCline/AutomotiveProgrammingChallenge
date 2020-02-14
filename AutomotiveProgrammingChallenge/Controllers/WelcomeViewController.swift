//
//  WelcomeViewController.swift
//  AutomotiveProgrammingChallenge
//
//  Created by Amanda Bloomer  on 2/8/20.
//  Copyright © 2020 Lucas Cline. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var fetchDealershipAndVehicleDataButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var dealershipsForSegue: [DealershipInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? DealershipTableViewController else {
            return
        }
        
        destinationVC.dealerships = dealershipsForSegue
    }
    
    @IBAction func letsBeginButtonTapped(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        fetchDealershipAndVehicleDataButton.isEnabled = false
        fetchDealershipAndVehicleDataButton.setTitle("Loading...", for: .normal)
        
        getAllAPIData()
    }
    
    //LUCAS - maybe this comment is stupid?
    //This method attempts to retrieve dealership and vehicle data. If successful, we navigate to the next screen, passing the dealership data along. If unsuccessful, we display an error to the user.
    private func getAllAPIData() {
        DataProvider.getAllAPIData { (response) in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.fetchDealershipAndVehicleDataButton.isEnabled = true
                self.fetchDealershipAndVehicleDataButton.setTitle("Get Dealership and Vehicle Data", for: .normal)
            }

            switch response {
            case .success(let dealerships):
                self.dealershipsForSegue = dealerships
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "DealershipSegue", sender: self)
                }
                break
            case .failure(let error):
                self.displayAlertForRequestFailureWith(error: error)
                break
            }
        }
    }
    
    private func displayAlertForRequestFailureWith(error: Error) {
        let alert = UIAlertController(title: "Server Error", message: "Unable to retrieve dealership and vehicle data. Please try again later. \n\nError: \(error.localizedDescription)", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
