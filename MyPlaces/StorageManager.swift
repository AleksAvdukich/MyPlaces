//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 25.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import RealmSwift

//создаем объект базы по требованиям
let realm = try! Realm()

class StorageManager {
    //реализуем в нем метод для сохранения объектов с типом Place
    static func saveObject(_ place: Place) {
        //сохранение в базу (смотрим документацию)
        try! realm.write {
            realm.add(place)
        }
    }

}

