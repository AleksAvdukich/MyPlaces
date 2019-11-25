//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 19.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    
//    var places = Place.savePlaces()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0 //данный метод итак возвращает 1, поэтому мы можем просто удалить этот метод и tableView будет по умолчанию иметь 1 секцию
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return places.count
//    }
    
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
//
//        let place = places[indexPath.row]
//
//        cell.nameLabel?.text = place.name
//        cell.locationLabel.text = place.location
//        cell.typeLabel.text = place.type
//
//        if place.image == nil {
//            cell.imageOfPlace?.image = UIImage(named: place.restaurantImage!) //тк имена файлов соответсвуют названиям заведений то мы можем подставить сюда значения из массива restaurantName
//        } else {
//            cell.imageOfPlace.image = place.image
//        }
//
//        cell.imageOfPlace?.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2 //imageView - квадрат, чтобы из него сделать кргу необходимо задать угол радиуса равный половине квадрата, тк высота изображения равна высоте строки, то для cornerRadius присваиваем половину высоты строки
//        cell.imageOfPlace?.clipsToBounds = true //для того чтобы изображение стало круглым необходимо обрезать его по границам imageView
//
//        return cell
//    }
 
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
//        places.append(newPlaceVC.newPlace!)
        tableView.reloadData()
    }

}
