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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var dealerships: [DealershipInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true
    }
    
    //LUCAS - there is a problem nothing to do with this method - when you retrieve dealerships from disk - no vehicle info is being stored.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationVC = segue.destination as? DealershipTableViewController else {
            print("Segue destination is not DealershipTableViewController - something went wrong.")
            return
        }
        
        destinationVC.dealerships = dealerships
    }
    
    @IBAction func letsBeginButtonTapped(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        letsBeginButton.isEnabled = false
        letsBeginButton.setTitle("Loading...", for: .normal)
        
        getAllAPIData()
    }
    
    private func getAllAPIData() {
        DataProvider.getAllAPIData { (response) in
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.letsBeginButton.isEnabled = true
                self.letsBeginButton.setTitle("Get Dealership and Vehicle Data", for: .normal)
            }

            switch response {
            case .success(let data):
                self.dealerships = data.allDealerships
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "DealershipSegue", sender: self)
                }
                break
            case .failure(let error):
                print(error)
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
