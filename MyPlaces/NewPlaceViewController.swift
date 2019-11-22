//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 22.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    @IBOutlet weak var imageOfPlace: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tableView.tableFooterView = UIView() //убираем разлиновку ячеек в нижней части tableView, там где нет контента
        
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

    
}


//MARK:- Text Field Delegate

extension NewPlaceViewController: UITextFieldDelegate {
    //скрываем клавиатуру по нажатию на done
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        imageOfPlace.image = info[.editedImage] as? UIImage//мы должны взять значение по конкретному ключу словаря info, ключами данного словаря являются свойства той самой структуры UIImagePickerController.InfoKey, свойства данной структуры определяют тип контента, и значения этих свойств мы будем присваивать нашему аутлету imageOfPlace. Взяли значение по ключу editedImage - info[.editedImage] и присвоили это значение как UIImage свойству imageOfPlace
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        //определившись с изображением и настроив его формат нам необъодимо закрыть imagePickerController
        dismiss(animated: true, completion: nil)
        //метод реализован и теперь надо определить кто будет делегировать обязанности по выполнению данного метода и кто будет выполнять данный метод (делегат), делегировать (передавать) выполнение данного метода должен объект с типом UIImagePickerController (определили в chooseImagePicker, объект imagePicker)
    }
}
