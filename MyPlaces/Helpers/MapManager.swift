//
//  MapManager.swift
//  
//
//  Created by Aleksandr Avdukich on 12.12.2019.
//

import UIKit
import MapKit

class MapManager {
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D? //принимает координаты заведения
    private var directionsArray: [MKDirections] = [] //массив в котором мы будем хранить маршруты
    private let regionInMeters = 1000.00
    
    //поработаем над маркером который будет указывать местоположение на карте
    func setupPlacemark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            //далее нужно привязать созданную аннотацию к конкретной точке на карте в соответствии с местоположением маркера
            guard let placemarkLocation = placemark?.location else { return }
            
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            //Далее нужно задать видимую область карты таким образом чтобы на ней были видны все созданные аннотации
            mapView.showAnnotations([annotation], animated: true)
            //выделяем созданную аннотацию
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //будет проверять включены ли у нас соответствующие службы на устройстве для работы с геопозицией
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        //возвращает булево значение, если службы геолокации доступны, то тут мы выполним первичные установки для дальнейшей работы, иначе вызываем алерт контроллер с инструкцией как включить эти службы
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled",
                               message: "To enable it go: Settings -> Privacy -> Location Services and turn On"
                )
            }
        }
    }
    
    //проверка статуса на разрешение использования геопозиции
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        //у класса CLLocationManager есть метод authorizationStatus который возвращает различные состояния авторизации приложения для служб геолокации, всего имеется 5 состояний и нам нужо обработать каждое из них
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse: //данный статус возвращается когда приложению разрешено определять геолокацию в момент его использования. Приполучении данного статуса будем отображать на карте локацию пользователя
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
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
    
    func showUserLocation(mapView: MKMapView) {
        //если нам получается определить координаты пользователя, то определяем регион для позиционирования карты
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        //определим координаты местоположения пользователя
        guard let location = locationManager.location?.coordinate else {
            //если не удается определить локацию то вызываем наш Алерт
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        //режим постоянного отслеживания текущего местоположения пользователя
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        //выполняем запрос на прокладку маршрута
        guard let request = createDirectionRequest(from: location) else { showAlert(title: "Error", message: "Destination is not found")
            return
        }
        //если все успешно то создаем маршрут на основе тех сведений которые у нас имеются в запросе
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions, mapView: mapView)
        
        //расчет маршрута
        directions.calculate { (response, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            //объект response содержит в себе массив routes с маршрутами
            for route in response.routes {
                //делаем перебор массива чтобы работать с каждым маршрутом в отдельности. Массив routes может содержать в себе один или несколько объектов MKRoute, каждый из которых представляет возможный набор направлений для пользователя. Если в настройках запроса на построение маршрута не запрашивать альтернативные маршруты, то этот массив будет содержать не более одного объекта. Каждый объект маршрута содержит сведения о геометрии которые можно использовать для отображения маршрута на карте, а также доп. информацию относящуюся к конкретному маршруту, такую как ожидаемое время в пути, дистанцию и все уведомления о поездке.
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути составит: \(timeInterval) сек.")
            }
        }
    }
    
    //настройка запроса на построение маршрута
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        //запрос возвращаем опциональный тк все зависит от того сможем ли мы определить координаты места назначения
        //местом назначения выступает заведение
        guard let destinationCoordinate = placeCoordinate else { return nil } //просто взять и выйти из метода мы не можем тк нам надо вернуть объект MKDirections.Request?, тк он опциональный мы можем просто вернуть nil
        //теперь надо определить метоположение точки для начала маршрута
        let startingLocation = MKPlacemark(coordinate: coordinate)//точка на карте
        let destination = MKPlacemark(coordinate: destinationCoordinate)//точка на карте
        //имея координаты 2-х точек на карте мы можем создать запрос на построение маршрута из точки А в точку B
        let request = MKDirections.Request() //данное св-во позволяет определить начальную и конечную точку маршрута, а также планируемый вид транспорта
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true //позволяет задать несколько маршрутов если есть альтернативные варианты
        
        return request
    }
    
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        
        closure(center)
        
    }
    
    //будем сбрасывать старые маршруты перед построением новых
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        //перед тем как построить маршрут удаляем с карты наложения текущего маршрута
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        //далее нужноперебрать все элементы массива directionsArray и отменить у каждого элемента из этого массива маршрут
        let _ = directionsArray.map { $0.cancel() }
        //удаляем все эл-ты из массива
        directionsArray.removeAll()
    }
    
    //возвращает текущие координаты точки находящиеся по центру экрана
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    //если службы геолокации доступны то из if вызываем
func setupLocationManager() {
        locationManager.delegate = self as! CLLocationManagerDelegate
        //точность определения местоположения пользователя
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        //определение окна поверх остальных окон
        alertWindow.windowLevel = UIWindow.Level.alert + 1
        //делаем наше окно ключевым и видимым
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true)
        
    }
    
}

