//
//  RoundButton.swift
//  maroschupkina1PW7
//
//  Created by Marina Roshchupkina on 16.01.2022.
//

import UIKit
class RoundButtonView: UIButton {
    
    convenience init(color: UIColor, text: String) {
        self.init()
        backgroundColor = color
        self.setTitle(text, for: .normal)
        self.layer.cornerRadius = 20
        isEnabled = false
        setTitleColor(.gray, for: .disabled)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 10).isActive = true
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 20).isActive = true
    }
}
