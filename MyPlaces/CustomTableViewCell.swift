//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Луиза on 04.11.2021.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    
    static let identifier = "Cell"
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            // отключаем возможность выставлять рейтинг на MainViewController
            cosmosView.settings.updateOnTouch = false
            cosmosView.settings.fillMode = .half
        }
    }
    
    
}
