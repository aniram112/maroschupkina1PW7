//
//  ViewController.swift
//  maroschupkina1PW7
//
//  Created by Marina Roshchupkina on 16.01.2022.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        configureUI()
        setupHideKeyboardOnTap()
        // Do any additional setup after loading the view.
    }
    
    private let map: MKMapView = {
        let mapView = MKMapView()
        mapView.layer.masksToBounds = true
        mapView.layer.cornerRadius = 5
        mapView.clipsToBounds = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 30
        //stack.backgroundColor = UIColor.systemGray6
        stack.distribution = .equalCentering
        stack.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layer.cornerRadius = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let startLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = .lightGray.withAlphaComponent(0.4)
        control.textColor = UIColor.black
        control.placeholder = "From"
        control.layer.cornerRadius = 20
        control.clipsToBounds = false
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode =
            UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment =
            UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    let finishLocation: UITextField = {
        let control = UITextField()
        control.backgroundColor = .lightGray.withAlphaComponent(0.4)
        control.textColor = UIColor.black
        control.placeholder = "To"
        control.layer.cornerRadius = 20
        control.clipsToBounds = false
        control.font = UIFont.systemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        control.autocorrectionType = UITextAutocorrectionType.yes
        control.keyboardType = UIKeyboardType.default
        control.returnKeyType = UIReturnKeyType.done
        control.clearButtonMode =
            UITextField.ViewMode.whileEditing
        control.contentVerticalAlignment =
            UIControl.ContentVerticalAlignment.center
        return control
    }()
    
    let goButton : RoundButtonView = {
        let goButton = RoundButtonView(color: .lightGray.withAlphaComponent(0.4), text: "Go")
        goButton.addTarget(self, action: #selector(goButtonWasPressed), for: .touchDown)
        return goButton
    }()
    
    let clearButton : RoundButtonView = {
        let clearButton = RoundButtonView(color: .lightGray.withAlphaComponent(0.4), text: "Clear")
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchDown)
        return clearButton
    }()
    
    @objc func clearButtonWasPressed(_ sender: UIButton) {
        sender.isEnabled = false
        goButton.isEnabled = false
        startLocation.text = ""
        finishLocation.text = ""
    }
    
    @objc func goButtonWasPressed(_ sender: UIButton) {
        sender.isEnabled = false
    }
    
    private func configureUI() {
        view.addSubview(map)
        map.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        map.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        map.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        buttonsStack.addArrangedSubview(goButton)
        buttonsStack.addArrangedSubview(clearButton)
        view.addSubview(buttonsStack)
        buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        buttonsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        buttonsStack.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 10).isActive = true
        buttonsStack.layer.masksToBounds = true
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        view.addSubview(textStack)
        textStack.spacing = 10
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        textStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10
        ).isActive = true
        textStack.addArrangedSubview(startLocation)
        textStack.addArrangedSubview(finishLocation)
        startLocation.delegate = self
        finishLocation.delegate = self
        
    }
    
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if startLocation.text != "" && finishLocation.text != "" {
            goButtonWasPressed(goButton)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if startLocation.text != "" && finishLocation.text != "" {
            goButton.isEnabled = true
            clearButton.isEnabled = true
        }
        else if startLocation.text != "" || finishLocation.text != "" {
            clearButton.isEnabled = true
            goButton.isEnabled = false
        }
        else {
            clearButton.isEnabled = false
            goButton.isEnabled = false
        }
    }
    
}

extension ViewController {
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(self.endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(self.endEditingRecognizer())
    }
    
    private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:)))
        tap.cancelsTouchesInView = false
        return tap
    }
}

