//
//  SummaryCell.swift
//  pocketMM
//
//  Created by Ly Cao on 4/27/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit
import Charts
class SummaryCell: UITableViewCell {

    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var C_image: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func commonInit(){
        self.index.sizeToFit()
        self.amount.sizeToFit()
        self.Name.sizeToFit()
        self.percent.sizeToFit()
    }
    
}
