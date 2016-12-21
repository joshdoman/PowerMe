//
//  LoginCell2.swift
//  WillYou
//
//  Created by Josh Doman on 12/13/16.
//  Copyright © 2016 Josh Doman. All rights reserved.
//

import UIKit

class RegisterChargerCell: UICollectionViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selectedCharger: String!
    
    let chargerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let chargerPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    lazy var titleView: UILabel = {
        let label = UILabel()
        label.text = "What type of charger do you use?"
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(30)
        label.textColor = UIColor(r: 110, g: 151, b: 261)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        selectedCharger = Model.options[0]
        chargerImageView.image = UIImage(named: selectedCharger)
        
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = UIColor(r: 210, g: 221, b: 261)

        addSubview(chargerPicker)
        addSubview(titleView)
        addSubview(chargerImageView)
        
        titleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10).isActive = true
        titleView.widthAnchor.constraint(equalTo: widthAnchor, constant: -50).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        chargerImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        chargerImageView.bottomAnchor.constraint(equalTo: titleView.topAnchor, constant: -20).isActive = true
        chargerImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        chargerImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        chargerPicker.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        chargerPicker.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -50).isActive = true
        chargerPicker.widthAnchor.constraint(equalTo: widthAnchor, constant: -100).isActive = true
        chargerPicker.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        chargerPicker.delegate = self
        chargerPicker.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Model.options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Model.options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCharger = Model.options[row]
        chargerImageView.image = UIImage(named: selectedCharger)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
