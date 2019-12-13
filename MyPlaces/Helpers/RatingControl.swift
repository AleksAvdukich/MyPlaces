//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Aleksandr Avdukich on 27.11.2019.
//  Copyright © 2019 Aleksandr Avdukich. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView { //@IBDesignable позволит отобразить контент которым мы наполнили stackView непосредственно в InterfaceBuilder, в этом случае любые изменения в коде будут в реальном времени отображаться в InterfaceBuilder
    //текущее значение рейтинга будем хранить в св-ве с типом Int, а кнопки поместим в массив с типом uibutton
    private var ratingsButton = [UIButton]()
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) //@IBInspectable для того чтобы св-во отобразилось в InterfaceBuilder, чтобы отобразилось надо явно инициализировать
    {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    

    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingsButton.firstIndex(of: button) else { return } //возвразает index первого выбранного элемента
        
        //Определяем рейтинг в соответствии с выбранной звездой
        let selectedRating = index + 1
        //если номер выбранной звезды будет совпадать с текущим рейтингом то нам необходимо будет обнулить этот рейтинг
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private Methods
    
    private func setupButtons() {
        
        for button in ratingsButton {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingsButton.removeAll() //очищает весь массив
        
        //Load Button Image
        //Bundle определяет местоположение ресурсов которые хранятся в каталоге нашего проекта
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let highlitedStar = UIImage(named: "highlitedStar",
                                    in: bundle,
                                    compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
            let button = UIButton()
            
            //Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlitedStar, for: .highlighted)
            button.setImage(highlitedStar, for: [.highlighted, .selected])
            
            button.translatesAutoresizingMaskIntoConstraints = false //отключает автоматически сгенерированные констрейнты для кнопки, если создавать св-ва програмно то его св-во translatesAutoresizingMaskIntoConstraints по умолчанию принимает значение true. Как правило при использовании autoLayout эти автоматически создаваемые констрейнты необходимо заменить собственными, для этого и устанавливаем зн-е для данного св-ва в положение false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button: )), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            //после каждой итерации нам нобходимо помещать созданную кнопку в массив ratingsButton
            ratingsButton.append(button)
        }
        
        updateButtonSelectionState()
    }
    //при вызове данного метода будем выполнять итерацию по всем кнопкам и устанавливать состояние каждой из них в соответствии с индексом и рейтингом
    private func updateButtonSelectionState() {
        //enumerated - возвращает пару объект и его индекс
        for (index, button) in ratingsButton.enumerated() { //в рейтинге номер текущей звезды
            button.isSelected = index < rating //если индекс < рейтинг то свойству isSelected будет присваиваться значение true и звезда будет заполненна, в противном случае звезда будет незаполненной
        }
    }
    
}
