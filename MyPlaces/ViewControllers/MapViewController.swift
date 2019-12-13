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

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?) //@objc optional означает метод не обязательный для реализации. Или второй вариант объевить расширение для данного протокола и тогда все методы будут не обязательными для выполнения
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    
    var place = Place() //здесь мы можем позволить себе принудительное извлечение тк данное св-во будет инициализировано значениями заведения которое мы будем передавать при переходе на этот VC
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? { //для хранения предыдущего местоположения пользователя
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        mapView.delegate = self //назначили делегатом сам класс
        setupMapView()
    }
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        //при нажатии на Done мы будем передавать в параметры метода getAddress текущее значени адреса и затем закрывать VC
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    private func setupMapView() {
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
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
    //будет вызываться каждый раз при смене отображаемого региона. И каждый раз при вызове данного метода будем тотбражать адрес который находится в центре текущего региона
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder() //отвечает за преобразование географических координат и географических названий
        //координаты преобразовываем в адрес
        
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        //освобождение ресурсов связанных с геокодированием делаем отмену отложенного запроса. Те карта возвращается на местоположение пользователя при ее смещении
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            
            if let error = error {
                print(error)
                return
            }
            //если ошибки нет то нам нужно извлечь массив меток
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            guard let streetName = placemark?.thoroughfare else { return }// номер улицы
            guard let buildNumber = placemark?.subThoroughfare else { return }//номер дома
            
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Хоть и создали наложения маршрута на карту оно у нас невидимое и для того чтобы его отобразить мы создадим лини по этому наложению
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    //данный метод вызывается при каждом изменении статуса авторизации нашего приложения для использования служб геолокации
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView,
                                              segueIdentifier: incomeSegueIdentifier)
    }
    
}
