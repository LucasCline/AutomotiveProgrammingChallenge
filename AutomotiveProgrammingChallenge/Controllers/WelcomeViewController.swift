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
    
    @IBAction func letsBeginButtonTapped(_ sender: Any) {
        getAllAPIData()
        //LUCAS - disable button on press
        //re-enable on fail
    }
    
    private func getAllAPIData() {
        DataProvider.getAllAPIData { (response) in
            switch response {
            case .success(let data):
                //navigate to the next screen
                //LUCAS -- print data or something? dont really need it here
                
                print("Downloading data successful - found \(data.allDealerships.count) dealerships and \(data.allVehicles.count) vehicles")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "DealershipSegue", sender: self)
                }
                break
            case .failure(let error):
                print(error)
                //LUCAS - Handle no data found
                //LUCAS - display error message and ask the user to try again
                break
            }
        }
    }
}
