//
//  PhoneConnecting.swift
//  CityGuide
//
//  Created by David Prochazka on 02.10.2025.
//

import WatchConnectivity

protocol PhoneConnecting {
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any])
}
