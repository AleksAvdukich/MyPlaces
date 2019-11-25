//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 19.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    var places: Results<Place>! //Results аналог массива
    //нам надо выполнить запрос к базе чтобы отобразить в интерфейсе хранящиеся в ней записи
    //нужно создать объект типа Results (тип библиотеки Realm)
    //Results - автообновляемый тип контейнера который возвращает запрашиваемые объекты, результаты всегда отображают текущее состояние хранилища в текущем потоке, в том числе и во время записи транзакций, те объект Results позволяет работать с данными в реальном времени, мы моем одновременно записывать в него данные и тут же их считывать
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //чтобы отобразить все заведения на экране приложения надо инициализировать ими наш объект places
        places = realm.objects(Place.self) //запрос объектов из realm и вызываем метод objects указав в качестве параметра тип запрашиваемых объектов
        //Place.self потому что в параметры нам надо подставить не сам объект Place, не саму модель данных, а именно тип Place, то мы сообщаем компилятору что под Place мы подрузамеваем тип данных
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0 //данный метод итак возвращает 1, поэтому мы можем просто удалить этот метод и tableView будет по умолчанию иметь 1 секцию
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //places мб пустым, пользователь может удалить все записи или при первом запуске приложения поле будет пустым
        return places.isEmpty ? 0 : places.count //если массив пустой возвращаем 0, а иначе количество элементов данной коллекции
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)

        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //imageView - квадрат, чтобы из него сделать кргу необходимо задать угол радиуса равный половине квадрата, тк высота изображения равна высоте строки, то для cornerRadius присваиваем половину высоты строки
        cell.imageOfPlace?.clipsToBounds = true //для того чтобы изображение стало круглым необходимо обрезать его по границам imageView

        return cell
    }
 
    // MARK: - Table View delegate

    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.saveNewPlace() //вызов данного метода произойдет прежде чем мы закроем ViewController
        tableView.reloadData()
    }

}

//будем сохранять в базу а в MainViewController будем отображать обращаясь к базе
