//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Луиза on 04.11.2021.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    static let identifier = "Cell"
    
    @IBOutlet weak var imageOfPlace: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    
}
