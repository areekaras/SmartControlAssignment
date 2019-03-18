//
//  LoginViewController.swift
//  SmartControlAssignment
//
//  Created by Shibili Areekara on 18/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    let MachineVCSegueId = "showMachineLisitingVC"
    
    //Store and retrieve token in/from keychain
    var token = ""
    
    
    var user:User? {
        didSet {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.MachineVCSegueId, sender: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.emailTF.text = AuthDetails.name
//        self.passwordTF.text = AuthDetails.password

    }
    @IBAction func loginTapped(_ sender: Any) {
        if !(self.emailTF.text ?? "").isEmpty && !(self.passwordTF.text ?? "").isEmpty {
            
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                
            }
            
            
            self.authenticateUser(url: BaseUrl.baseUrl.rawValue + RelativeUrl.login.rawValue)
        }
        else {
            self.showAlert(message: "Enter Auths")
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as? UINavigationController
        
        let machineListingTVC = navVC?.viewControllers.first as! MachinesListingTVController
        
        machineListingTVC.userToken = self.token
        machineListingTVC.user = self.user
    }

}

extension LoginViewController {
    private func authenticateUser(url : String) {
        let service = Service()
        service.setConfigUrl(url)
        service.requestMethod(RequestMethod.POST.rawValue)
        service.loginUser(email: self.emailTF.text ?? "", password: self.passwordTF.text ?? ""){ [weak self] (data, action, serviceStatus) in
            print(data ?? "")
            
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
            
            if serviceStatus == ServiceStatus.FAILED.rawValue {
                print("failure")
                
            }
            else {
                guard let data = data else { return }
                
                do {
                    print(data)
                    let response = try JSONDecoder().decode(ResponseData.self, from: data)
                    
                    guard let userData = response.data else { return }
                    
                    //*****Store this token to KeyChain
                    guard let user = userData.user else { return }
                    
                    guard let token = userData.token else { return }
                    
                    self?.user = user
                    self?.token = token
                    
                    print(userData)
                }
                catch let jsonErr {
                    print("jsonErr :: \(jsonErr)")
                }
            }
        }
    }
    
    func showAlert(message:String) {
        let alert  = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
