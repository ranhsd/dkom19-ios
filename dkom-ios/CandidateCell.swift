//
//  CandidateCell.swift
//  dkom-ios
//
//  Created by Ran Hassid on 08/01/2019.
//  Copyright © 2019 Trench Girls LTD. All rights reserved.
//

import UIKit
import Kingfisher

class CandidateCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with candidate: TFCandidate) {
        
        if let photoStringURL = candidate.profilePicture?.url {
            let url = URL(string: photoStringURL)
            self.photoImageView.kf.setImage(with: url, options: [.transition(.fade(0.5))])
        }
        
        
    }
    
}
