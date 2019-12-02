//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 01.12.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place() //здесь мы можем позволить себе принудительное извлечение тк данное св-во будет инициализировано значениями заведения которое мы будем передавать при переходе на этот VC
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self //назначили делегатом сам класс
        setupPlacemark()
        checkLocationServices()
        
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
    //будет проверять включены ли у нас соответствующие службы на устройстве для работы с геопозицией
    private func checkLocationServices() {
        //возвращает булево значение, если службы геолокации доступны, то тут мы выполним первичные установки для дальнейшей работы, иначе вызываем алерт контроллер с инструкцией как включить эти службы
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    //если службы геолокации доступны то из if вызываем
    private func setupLocationManager() {
        locationManager.delegate = self
        //точность определения местоположения пользователя
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    //проверка статуса на разрешение использования геопозиции
    private func checkLocationAuthorization() {
        //у класса CLLocationManager есть метод authorizationStatus который возвращает различные состояния авторизации приложения для служб геолокации, всего имеется 5 состояний и нам нужо обработать каждое из них
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //данный статус возвращается когда приложению разрешено определять геолокацию в момент его использования. Приполучении данного статуса будем отображать на карте локацию пользователя
            mapView.showsUserLocation = true
            break
        case .denied: //данный статус получаем когда приложению запрещено использовать службы геолокации, также если сулжбе геолокации отключены в настройках, в этом случае необходимо сообщить пользователю и объяснить как авторизовать приложение
            //Show Alert Controller
            break
        case .notDetermined: //статус неопределен. Возвращается если пользователь еще не сделал выбор относительно того может ли это приложение использовать службы геолокации
            locationManager.requestWhenInUseAuthorization()
        case .restricted: //возвращается если приложение не авторизовано для использования служб геолокации
            break
        case .authorizedAlways: //возвращается когда рпиложениею разрешено использовать службы геолокации постоянно
            break
        //Свифт реализует все перечисления, но само перечисление может в будущем дополниться допонительными кейсами, для этого реализуется данная ветка
        @unknown default:
            print("New case is available")
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //мы пока не определяем свое текущее положение на карте поэтому сразу исключим этот вариант
        //если маркером на карте является текущее местоположение пользователя те если annotation является объектом MKUserLocation, то вообще не должны создавать никакой аннотации
        guard !(annotation is MKUserLocation) else { return nil }
        //далее надо создать объект MKAnnotationView, который и представляет view с аннотацией на карте
        //но вместо того чтобы создавать новое представление при каждом вызове этого метода в документации рекомендуется переиспользовать ранее созданные аннотации этого же типа
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        //в том случае если на карте все таки не окажется ни одного представления с аннотацией, которое мы могли бы переиспользовать, то инициализируем этот объект новым значением присвоив ему объект класса MKAnnotaionView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            //для того чтобы отобразить аннотацию в виде баннера, необходимо св-ву canShowCallout = true
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView //изображение размещаем справа
        }
        
        return annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    //данный метод вызывается при каждом изменении статуса авторизации нашего приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServices()
    }
    
}
