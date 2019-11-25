//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 21.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import RealmSwift

//Меняем стр-ру на класс в соотв с требованиями Realm
class Place: Object {
    //у классов нет собственных инициализаторов, поэтому надо либо создавать его, либо инициализировать свойства модели
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var type: String?
//    @objc dynamic var restaurantImage: String? //image - String тк к изображениями обращаемся по имени файла
    
    let restaurantNames = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    //static - те для обращения к методу стр-ры надо сначал обратиться к самой стр-ре
    //метод который будет генерировать объекты типа Place с названиями из массива restaurantNames
    //нам не нужно будет возвращать массив тк при использовании базы данных нам не надо будет передавать записи на основной экран, нам достаточно будет сохранить все заведения в базу а для дальнейшей работы с ними нужно будет просто обратиться к самой базе данных
    func savePlaces() {
        for place in restaurantNames {
            //перед тем как присвоить изображения наших ресторанов св-ву image, нам надо перевести его тип в тип Data
            let image = UIImage(named: place)
            //теперь когда есть изображение текущего заведения, мы можем попытаться перевести это изображение в тип Data
            guard let imageData = image?.pngData() else { return } //метод pngData позволяет сконвертировать в тип Data
            
            let newPlace = Place()
            
            newPlace.name = place
            newPlace.location = "Ufa"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData
            
            //вызываем метод для сохранения всех заведений в Базе
            StorageManager.saveObject(newPlace)
        }
    }
    
}
