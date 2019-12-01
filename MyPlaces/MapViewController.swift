//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 01.12.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    var place: Place! //здесь мы можем позволить себе принудительное извлечение тк данное св-во будет инициализировано значениями заведения которое мы будем передавать при переходе на этот VC
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlacemark()

    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    //поработаем над маркером который будет указывать местоположение на карте
    private func setupPlacemark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder() //отвечает за преобразование географических координат и географических названий
        //позволяет определить местоположение на карте по адресу переданному в параметры этого метода в виде строки
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            //placemarks - массив меток
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first //тк ищем местоположение по конкретному адресу то массив placemarks должен содержать всего одну метку. Присваиваем 1ое значение из массива placemarks. Получили метку на карте
            
            //Маркер - это всего лишь координата на карте и для того чтобы описать точку на которую указывает маркер необходимо воспользоваться объектом класса MKPointAnnotation()
            let annotation = MKPointAnnotation() //данный объект используется для того чтобы описать какую то точку на карте
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            //далее нужно привязать созданную аннотацию к конкретной точке на карте в соответствии с местоположением маркера
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            
            //Далее нужно задать видимую область карты таким образом чтобы на ней были видны все созданные аннотации
            self.mapView.showAnnotations([annotation], animated: true)
            //выделяем созданную аннотацию
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
   

}
