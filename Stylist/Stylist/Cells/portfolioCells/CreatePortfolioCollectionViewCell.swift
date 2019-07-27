//
//  CreatePortfolioCollectionViewCell.swift
//  Stylist
//
//  Created by Oniel Rosario on 7/9/19.
//  Copyright © 2019 Ashli Rankin. All rights reserved.
//

import UIKit

class CreatePortfolioCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoButton: UIButton!
    
    func setupCell(target: CreatePortfolioViewController, action: Selector) {
       photoButton.addTarget(target, action: action, for: .touchUpInside)
      photoButton.isEnabled = true
     layer.cornerRadius = layer.frame.height / 2
    }
    
}
