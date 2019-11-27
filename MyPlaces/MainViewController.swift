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
    
    private let searchController = UISearchController(searchResultsController: nil) //передавая nil мы сообщаем контроллеру поиска что для отображения результата поиска хотим использовать тот же view в котором отображается основной контент, те отображать результаты поиска мы будем все на том же ViewController в котором и происходит сам поиск, для этого класс MainViewController доджен быть подписан под протокол UISearchResultsUpdating, методы данного протокола отвечают за обновления результатов поиска на основе той информации которую пользователь вносит в поисковую строку
    private var places: Results<Place>! //Results аналог массива
    //нам надо выполнить запрос к базе чтобы отобразить в интерфейсе хранящиеся в ней записи
    //нужно создать объект типа Results (тип библиотеки Realm)
    //Results - автообновляемый тип контейнера который возвращает запрашиваемые объекты, результаты всегда отображают текущее состояние хранилища в текущем потоке, в том числе и во время записи транзакций, те объект Results позволяет работать с данными в реальном времени, мы моем одновременно записывать в него данные и тут же их считывать
    private var filteredPlaces: Results<Place>! //будем хранить отфильтрованные значения
    private var ascendingSorting = true //сортировка по возрастанию
    //при нажатии на кнопку сортировки в обратном порядке мы должны будем поменять значение св-ва ascendingSorting на противоположное
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false } //если данное значение вернуть не удастся мы должны вернуть false
        return text.isEmpty //те если строка поиска будет пустой то вернется true
    }//будет возвращать true или false в зависимости от того активна ли строка поиска или нет
    
    private var isFiltering: Bool { //будет возвращать значение true в том случае когда поисковый запрос будет активирован
        return searchController.isActive && !searchBarIsEmpty //будет возвращать значение true когда строка поиска активирована и при этом не является пустой
        //в зависимости от возвращаемого значение этого св-ва в интерфейсе приложения нам надо отображать объекты из соотв. массивов
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //чтобы отобразить все заведения на экране приложения надо инициализировать ими наш объект places
        places = realm.objects(Place.self) //запрос объектов из realm и вызываем метод objects указав в качестве параметра тип запрашиваемых объектов
        //Place.self потому что в параметры нам надо подставить не сам объект Place, не саму модель данных, а именно тип Place, то мы сообщаем компилятору что под Place мы подрузамеваем тип данных
     
        //Setup the search controller
        searchController.searchResultsUpdater = self //мы тем самым говорим что получтелем информации об изменении текста в поисковой строке должен быть наш класс
        searchController.obscuresBackgroundDuringPresentation = false //по умолчанию ViewController с результатами поиска не позволяет взаимодействовать с отображаемым контентом и если отключить этот параметр то это позволит взаимодействовать с этим VC как с основным
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController //строка поиска будет интегрирована в NavigationBar
        definesPresentationContext = true //позволяет отпустить строку поиска при переходе на другой экран
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0 //данный метод итак возвращает 1, поэтому мы можем просто удалить этот метод и tableView будет по умолчанию иметь 1 секцию
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        //places мб пустым, пользователь может удалить все записи или при первом запуске приложения поле будет пустым
        return places.isEmpty ? 0 : places.count //если массив пустой возвращаем 0, а иначе количество элементов данной коллекции
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        var place = Place()
        
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        } else {
            place = places[indexPath.row]
        }

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
            let place: Place
            if isFiltering {
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
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

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    //будет заниматься фильтрацией контента в соответствии с поисковым запросом
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText) //[c] - characters - те мы не будем смотреть на регистр символов; %@ должны будем заменить конкретной переменной. searchText как для первой пары символов %@ так и для второй пары символов %@
        //означает что мы должны будем выполнять поиск по полю name и location и фильтровать данные мы будем из значения searchText вне зависимости от регистра символов
        tableView.reloadData()
    }
    
}
