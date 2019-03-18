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
        self.emailTF.becomeFirstResponder()
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        self.loginAction()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as? UINavigationController
        
        let machineListingTVC = navVC?.viewControllers.first as! MachinesListingTVController
        
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
            
            guard let data = data else { return }
            
            do {
                print(data)
                let response = try JSONDecoder().decode(ResponseData.self, from: data)
                
                if serviceStatus == ServiceStatus.FAILED.rawValue || response.status == 0 {
                    DispatchQueue.main.async {
                        self?.showAlert(message: response.message ?? "Error")                    }
                    return
                }
                
                guard let userData = response.data else { return }
                guard let user = userData.user else { return }
                
                guard let token = userData.token else { return }
                DAKeychain.shared["token"] = token
                
                self?.user = user
               
                print(userData)
            }
            catch let jsonErr {
                print("jsonErr :: \(jsonErr)")
            }
        }
        
    }
    
    func showAlert(message:String) {
        let alert  = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func loginAction() {
        if (self.emailTF.text ?? "").isEmpty
        {
            self.showAlert(message: "Enter email")
        }
        else if (self.passwordTF.text ?? "").isEmpty {
            self.showAlert(message: "Enter password")
        }
        else {
            self.activityIndicator.startAnimating()
            self.authenticateUser(url: BaseUrl.baseUrl.rawValue + RelativeUrl.login.rawValue)
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        }
        else if textField == passwordTF {
            passwordTF.resignFirstResponder()
            self.loginAction()
        }
        
        return true
    }
    
}

public struct AuthDetails {
    static var name = "christoph.halang+apple@z-lab.com"
    static var password = "someTEST"
}
