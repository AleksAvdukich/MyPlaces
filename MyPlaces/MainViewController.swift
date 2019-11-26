//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 19.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    var places: Results<Place>! //Results аналог массива
    //нам надо выполнить запрос к базе чтобы отобразить в интерфейсе хранящиеся в ней записи
    //нужно создать объект типа Results (тип библиотеки Realm)
    //Results - автообновляемый тип контейнера который возвращает запрашиваемые объекты, результаты всегда отображают текущее состояние хранилища в текущем потоке, в том числе и во время записи транзакций, те объект Results позволяет работать с данными в реальном времени, мы моем одновременно записывать в него данные и тут же их считывать
    var ascendingSorting = true //сортировка по возрастанию
    //при нажатии на кнопку сортировки в обратном порядке мы должны будем поменять значение св-ва ascendingSorting на противоположное
    
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //places мб пустым, пользователь может удалить все записи или при первом запуске приложения поле будет пустым
        return places.isEmpty ? 0 : places.count //если массив пустой возвращаем 0, а иначе количество элементов данной коллекции
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    //метод позволяющий вызывать различные пункты меню свайпом по ячейке справа налево
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let place = places[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            //удаление объекта из базы не удаляет саму строку, поэтому надо вызвать следующий метод
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
    
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            //то передаем на newPlaceViewController выбранную запись
            //нам необходимо извлечь конкретный объект находящийся в ячейке из массива places, в массиве он хранится по тому же индексу который соответствует индексу текущей ячейки
            //необходимо определить индекс выбранной ячейки, за это отвечает св-во tableView - indexPathForSelectedRow к-ое возвращает опциональное значение
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            //имея индекс текущей строки мы можем извлечь объект из массива places по этому индексу
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
            //тем самым передали объект из выбранной ячейки на NewPlaceViewController
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace() //вызов данного метода произойдет прежде чем мы закроем ViewController
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
        
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        ascendingSorting.toggle() //меняет значение на противоположное
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
        tableView.reloadData()
    }
}

//будем сохранять в базу а в MainViewController будем отображать обращаясь к базе
