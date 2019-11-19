//
//  MainViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 19.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {

    let restaurantName = [
        "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
        "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
        "Классик", "Love&Life", "Шок", "Бочка"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0 //данный метод итак возвращает 1, поэтому мы можем просто удалить этот метод и tableView будет по умолчанию иметь 1 секцию
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantName.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = restaurantName[indexPath.row]

        return cell
    }
 
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
