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
    let regionInMeters = 10_000.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        
        mapView.delegate = self //назначили делегатом сам класс
        setupMapView()
        checkLocationServices()
        
    }
    
    @IBAction func centerViewInUserLocation() {
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled",
                          message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                )
            }
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
            if incomeSegueIdentifier == "getAddress" { showUserLocation() }
            break
        case .denied: //данный статус получаем когда приложению запрещено использовать службы геолокации, также если службы геолокации отключены в настройках, в этом случае необходимо сообщить пользователю и объяснить как авторизовать приложение
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location is not Available",
                               message: "To give permission Go to: Settings -> MyPlaces -> Location"
                )
            }
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
    
    private func showUserLocation() {
        //если нам получается определить координаты пользователя, то определяем регион для позиционирования карты
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    //возвращает текущие координаты точки находящиеся по центру экрана
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        present(alert, animated: true)
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
    //будет вызываться каждый раз при смене отображаемого региона. И каждый раз при вызове данного метода будем тотбражать адрес который находится в центре текущего региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder() //отвечает за преобразование географических координат и географических названий
        //координаты преобразовываем в адрес
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            //если ошибки нет то нам нужно извлечь массив меток
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare // номер улицы
            let buildNumber = placemark?.subThoroughfare //номер дома
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName), \(buildNumber)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    //данный метод вызывается при каждом изменении статуса авторизации нашего приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServices()
    }
    
}
