//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 21.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit

struct Place {
    
    var name: String
    var location: String?
    var image: UIImage?
    var type: String?
    var restaurantImage: String? //image - String тк к изображениями обращаемся по имени файла
    
    static let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    //static - те для обращения к методу стр-ры надо сначал обратиться к самой стр-ре
    //метод который будет генерировать объекты типа Place с названиями из массива restaurantNames
    static func getPlaces() -> [Place] {
        var places = [Place]() //пустой массив с типом Place
        //создадим цикл в котором будем последовательно перебирать все эл-ты массива restaurantNames
        //будем добавлять в массив places объекты с типом Place св-ва которых будут инициализированы значениями из массива restaurantNames
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Уфа", image: nil, type: "Ресторан", restaurantImage: place))
        }
        
        return places
    }
    
}
