//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Георгий on 23.05.2025.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
}
