//
//  ViewController.swift
//  maroschupkina1PW7
//
//  Created by Marina Roshchupkina on 16.01.2022.
//

import UIKit
import CoreLocation
import MapKit
import YandexMapsMobile

class ViewController: UIViewController {
    var coordinates: [CLLocationCoordinate2D] = []
    var drivingSession: YMKDrivingSession?
    var length = 0.0;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        configureUI()
        setupHideKeyboardOnTap()
        
        // Do any additional setup after loading the view.
    }
    
    /*private let map: MKMapView = {
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
     }()*/
    
    private let map: YMKMapView = {
        let map = YMKMapView()
        map.clearsContextBeforeDrawing = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
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
        control.backgroundColor = .darkGray.withAlphaComponent(0.5)
        control.placeholder = "From"
        control.layer.cornerRadius = 20
        control.clipsToBounds = false
        control.font = UIFont.boldSystemFont(ofSize: 15)
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
        control.backgroundColor = .darkGray.withAlphaComponent(0.5)
        control.placeholder = "To"
        control.layer.cornerRadius = 20
        control.clipsToBounds = false
        control.font = UIFont.boldSystemFont(ofSize: 15)
        control.borderStyle = UITextField.BorderStyle.roundedRect
        //control.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.5).cgColor
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
        let goButton = RoundButtonView(color: .gray.withAlphaComponent(0.2), text: "Go")
        goButton.addTarget(self, action: #selector(goButtonWasPressed), for: .touchDown)
        return goButton
    }()
    
    let clearButton : RoundButtonView = {
        let clearButton = RoundButtonView(color: .gray.withAlphaComponent(0.2), text: "Clear")
        clearButton.addTarget(self, action: #selector(clearButtonWasPressed), for: .touchDown)
        return clearButton
    }()
    
    let distanceView : RoundButtonView = {
        let distanceView = RoundButtonView(color: .gray.withAlphaComponent(0.2), text: "0")
        return distanceView
    }()
    
    @objc func clearButtonWasPressed(_ sender: UIButton) {
        sender.isEnabled = false
        goButton.isEnabled = false
        startLocation.text = ""
        finishLocation.text = ""
        coordinates.removeAll()
        map.mapWindow.map.mapObjects.clear()
    }
    
    @objc func goButtonWasPressed(_ sender: UIButton) {
        
        coordinates.removeAll()
        map.mapWindow.map.mapObjects.clear()
        
        
        sender.isEnabled = false
        guard
            let first = startLocation.text,
            let second = finishLocation.text,
            first != second
        else {
            return
        }
        let group = DispatchGroup()
        group.enter()
        getCoordinateFrom(address: first, completion: { [weak
                                                            self] coords,_ in
            if let coords = coords {
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        group.enter()
        getCoordinateFrom(address: second, completion: { [weak
                                                            self] coords,_ in
            if let coords = coords {
                self?.coordinates.append(coords)
            }
            group.leave()
        })
        group.notify(queue: .main) {
            DispatchQueue.main.async { [weak self] in
            }
            self.buildPath()
            //self.map.delegate = self
        }
    }
    private func buildPath(){
        
        //let startMark = MKPlacemark(coordinate: coordinates[0])
        let startMark = YMKPoint(latitude: coordinates[0].latitude, longitude: coordinates[0].longitude)
        
        let finishMark = YMKPoint(latitude: coordinates[1].latitude, longitude: coordinates[1].longitude)
        
        map.mapWindow.map.move(with: YMKCameraPosition(
                                target: startMark,
                                zoom: 6,
                                azimuth: 0,
                                tilt: 0))
        
        let requestPoints : [YMKRequestPoint] = [
            YMKRequestPoint(point: startMark, type: .waypoint, pointContext: nil),
            YMKRequestPoint(point: finishMark, type: .waypoint, pointContext: nil),
        ]
        
        let responseHandler = {(routesResponse: [YMKDrivingRoute]?, error: Error?) -> Void in
            if let routes = routesResponse {
                self.onRoutesReceived(routes)
            } else {
                self.onRoutesError(error!)
            }
        }
        
        
        let drivingRouter = YMKDirections.sharedInstance().createDrivingRouter()
        drivingSession = drivingRouter.requestRoutes(
            with: requestPoints,
            drivingOptions: YMKDrivingDrivingOptions(),
            vehicleOptions: YMKDrivingVehicleOptions(),
            routeHandler: responseHandler)
        
        
        distanceView.setTitle(String(Int(length)), for: UIControl.State.normal)
    }
    
    func onRoutesReceived(_ routes: [YMKDrivingRoute]) {
        let mapObjects = map.mapWindow.map.mapObjects
        length = 0
        for section in routes[0].sections{
            length += section.metadata.weight.distance.value
        }
        
        distanceView.setTitle(String(Int(length)), for: UIControl.State.normal)
        
        let routePolyline = mapObjects.addColoredPolyline(with: routes[0].geometry);
        YMKRouteHelper.updatePolyline(withPolyline: routePolyline, route: routes[0], style: YMKRouteHelper.createDefaultJamStyle())
        
    }
    
    func onRoutesError(_ error: Error) {
        let routingError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if routingError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if routingError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getCoordinateFrom(address: String, completion:
                                    @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?)
                                    -> () ) {
        DispatchQueue.global(qos: .background).async {
            CLGeocoder().geocodeAddressString(address)
                { completion($0?.first?.location?.coordinate, $1) }
        }
    }
    
    private func configureUI() {
        view.addSubview(map)
        map.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        map.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        map.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        map.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        goButton.addBlurEffect(style: .systemUltraThinMaterial, cornerRadius: 20, padding: 0)
        distanceView.addBlurEffect(style: .systemUltraThinMaterial, cornerRadius: 20, padding: 0)
        clearButton.addBlurEffect(style: .systemUltraThinMaterial, cornerRadius: 20, padding: 0)
        distanceView.isEnabled = true;
        
        buttonsStack.addArrangedSubview(goButton)
        buttonsStack.addArrangedSubview(distanceView)
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

extension ViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .red
        renderer.lineWidth = 5.0
        
        return renderer
    }
}

