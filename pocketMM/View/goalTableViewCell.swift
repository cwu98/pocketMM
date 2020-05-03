//
//  goalTableViewCell.swift
//  pocketMM
//
//  Created by Shifan on 5/2/20.
//  Copyright © 2020 NYU. All rights reserved.
//

import UIKit

class goalTableViewCell: UITableViewCell {

 
    
  
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var goalImage: UIImageView!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var save: UILabel!
    @IBOutlet weak var progressBar: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("awake from nib goaltableViewCell")
        // Initialization code
        self.name.sizeToFit()
        self.progress.sizeToFit()
        self.save.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func commonInit(){
        self.name.sizeToFit()
        self.progress.sizeToFit()
        self.save.sizeToFit()
        
    }
}
