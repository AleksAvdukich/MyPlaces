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
    @objc dynamic var date = Date() //для внутреннего использования и пользователю оно дотупно не будет, мы всегда будем инициализировать его текущей датой и использовать это значение для сортировки по дате добавления
    @objc dynamic var rating = 0.0
    
    //назначенный инициализатор который предназначен для того чтобы полностью инициализировать все св-ва представленные классом
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        //такого вида инициализатор должен вызывать инициализатор самого класса с пустыми параметрами, это делается для того чтобы мы для начала инициализировали все св-ва значениями по умолчанию
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        //наш инициализатор не является обязательным, сейчас мы можем создать экземпляр класса как без инициализации его свойств так и с инициализацией.
        //Такой инициализатор не создает объект а присваивает новые значения уже созданному объекту
        self.rating = rating
    }
    
}
