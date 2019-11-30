//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 21.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace?.layer.cornerRadius = imageOfPlace.frame.size.height / 2 //imageView - квадрат, чтобы из него сделать кргу необходимо задать угол радиуса равный половине квадрата, тк высота изображения равна высоте строки, то для cornerRadius присваиваем половину высоты строки
            imageOfPlace?.clipsToBounds = true //для того чтобы изображение стало круглым необходимо обрезать его по границам imageView
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false //отключаем возможность менять количество звезд на главном экране
        }
    }
    
}
