//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 22.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    //объект в который мы будем передавать выбранную запись
    var currentPlace: Place?
    
    var imageIsChanged = false
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //при выполнении непосредственно записи в базу данных поток в котором выполняется данное действие полностью замораживается на время транзакции, те если запись в БД предполагает хоть какую-то задержку по времени то лучше это делать в фоновом потоке
//        DispatchQueue.main.async {
//            self.newPlace.savePlaces()
//            //чтение данных из базы не блокирует основной поток и можно обращаться к данным прямо во время записи из любого потока, те можно получать доступ к объекту сразу как он появляется в базе без обновления интерфейса
//        }
    
        tableView.tableFooterView = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: tableView.frame.size.width,
                                                         height: 1)) //убираем разлиновку ячеек в нижней части tableView, там где нет контента
        
        saveButton.isEnabled = false

        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        setupEditScreen()
    }
    
    //MARK: Table View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //если наша первая ячейка =0, то мы должны вызвать меню для того чтобы пользователь выбрал изображение
        if indexPath.row == 0 {
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo-1")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            //actionSheet - списко действий. Теперб должны определить список действий в пользовательском меню, этот списко будет состоять из 2х пунктов: Камера и Фото, также будет кнопка Cancel
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                //в теле блока вызываем метод который позвоит сделать фото при помощи устройства
                self.chooseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            //Определили 3 пользовательских действий и теперь необходимо вписать эти действия в AlertController
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            //иначе мы должны скрыть клавиатуру
        } else {
            view.endEditing(true)
        }
    }
    //будем передавать значения заполненных полей в соответствующие свойства нашей модели
    func savePlace() {
        
        var image: UIImage?
        //если изображение было изменено пользователем
        if imageIsChanged {
            image = placeImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData() //конвертация UIImage в Data
        
        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: imageData)
        
        if currentPlace != nil {
            //меняем текущее значение currentPlace на новое
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
            }
        } else {
            StorageManager.saveObject(newPlace) //сохраняем в базу
        }
    }
    //приватный метод в котором будем работать над экраном редактирования записи
    private func setupEditScreen() {
        //все что мы будем выполнять в данном методе должно быть применено только в случае редактирования записи, это можно определить по наличию или отсутствию объекта currentPlace, данный объект имеет опциональный тип, при добавлении новой записи мы в него ничего не передаем и соотв. currentPlace остается инициализированным значением nil
        if currentPlace != nil {
            
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill //позволяет масштабировать изображение по содержимому imageView
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
        }
    }
    
    private func setupNavigationBar() {
        //убираем MyPlaces из VC
        if let topItem = navigationController?.navigationBar.topItem {
            //backBarButtonItem - кнопка возврата
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
}

//MARK:- Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == true {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
}

//MARK: Work with image
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //source позволит определять источник для выбора изображения
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        //при вызове метода chooseImagePicker мы должны определить источник выбора изображений, если этот источник будет доступен то тогда уже создаем экземпляр UIImagePickerController
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self  //imagePicker.delegate - imagePicker делегирует (передает), и надо определить объект который будет выполнять данный метод (те назначить делегата), это будет наш класс - self
            imagePicker.allowsEditing = true //пользователь сможет отредактировать изображение
            imagePicker.sourceType = source //определяем тип источника для выбранного изображения
            present(imagePicker, animated: true)
        }
    }
    
    //позволяет использовать отредактированное пользователем изображение
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //здесь присваиваем аутлету imageOfPlace изображение которое выбирает пользователь
        placeImage.image = info[.editedImage] as? UIImage//мы должны взять значение по конкретному ключу словаря info, ключами данного словаря являются свойства той самой структуры UIImagePickerController.InfoKey, свойства данной структуры определяют тип контента, и значения этих свойств мы будем присваивать нашему аутлету imageOfPlace. Взяли значение по ключу editedImage - info[.editedImage] и присвоили это значение как UIImage свойству imageOfPlace
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        //если значение imageIsChanged = true то мы не будем менять фоновую картинку, в противном случае меняем
        imageIsChanged = true
        
        //определившись с изображением и настроив его формат нам необъодимо закрыть imagePickerController
        dismiss(animated: true, completion: nil)
        //метод реализован и теперь надо определить кто будет делегировать обязанности по выполнению данного метода и кто будет выполнять данный метод (делегат), делегировать (передавать) выполнение данного метода должен объект с типом UIImagePickerController (определили в chooseImagePicker, объект imagePicker)
    }
}


