//
//  MachinesListingTVController.swift
//  SmartControlAssignment
//
//  Created by Shibili Areekara on 18/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import UIKit

class MachinesListingTVController: UITableViewController {

    let machinceCellId = "MachineDisplayTVCell"
    
    
    var user:User? {
        didSet {
            guard let companyId = user?.company?.id else { return }
            
            self.getMachineList(companyId:companyId, url: BaseUrl.baseUrl.rawValue + RelativeUrl.machineList.rawValue)
        }
    }
    
    //Store and retieve user details in and from KeyChain
    var userToken = ""
    var companyId: Int = 0
    
    var machines: [Asset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

// MARK: - Table view Functionalities
extension MachinesListingTVController {
    
    private func setUpTableView() {
        self.registerCells()
        
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func registerCells() {
        self.tableView.register(UINib(nibName: machinceCellId, bundle: nil), forCellReuseIdentifier: machinceCellId)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return machines.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: machinceCellId, for: indexPath) as? MachineDisplayTVCell else { return UITableViewCell() }
    
        cell.machine = machines[indexPath.row]
        
        return cell
    }

}

extension MachinesListingTVController {
    
    
    func getMachineList(companyId:Int, url : String) {
        let service = Service()
        service.setConfigUrl(url)
        service.setCompanyId(companyId)
        service.requestMethod(RequestMethod.GET.rawValue)
        service.setToken(userToken)
        service.getMachineList{ [weak self] (data, action, serviceStatus) in
            print(data ?? "")
            if serviceStatus == ServiceStatus.FAILED.rawValue {
                
            }
            else {
                guard let data = data else { return }
                
                do {
                    print(data)
                    
                    let response = try JSONDecoder().decode(AssetsApiDats.self, from: data)
                    
                    guard let machines = response.data?.assets else { return }
                    
                    self?.machines = machines
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
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