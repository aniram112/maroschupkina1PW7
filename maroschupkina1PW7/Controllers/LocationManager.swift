//
//  LocationManager.swift
//  maroschupkina1PW7
//
//  Created by Marina Roshchupkina on 28.01.2022.
//

import UIKit
import CoreLocation

extension ViewController: CLLocationManagerDelegate {
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
            //print (heading.magneticHeading)
            azimuth = heading.magneticHeading
            updateCompass(heading: (Double(heading.magneticHeading)))
        }
    
}
