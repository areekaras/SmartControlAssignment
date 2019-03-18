//
//  MachineDisplayTVCell.swift
//  SmartControlAssignment
//
//  Created by Shibili Areekara on 18/03/19.
//  Copyright © 2019 Shibili Areekara. All rights reserved.
//

import UIKit

class MachineDisplayTVCell: UITableViewCell {
    
    @IBOutlet weak var machineImageView: CustomImageView!
    @IBOutlet weak var machineNameLabel: UILabel!
    
    var machine:Asset? {
        didSet {
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.machineNameLabel.text = ""
        
        self.machineImageView.image = nil
    }

    func updateView() {
        self.machineNameLabel.text = machine?.name ?? ""
        
        guard let imageUrl = machine?.image?.url else { return }
        self.machineImageView.loadImageFromUrl(urlString: imageUrl)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
