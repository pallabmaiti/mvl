//
//  Booking.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation

struct Booking {
    struct Location {
        let id: UUID
        let latitude: Double
        let longitude: Double
        let aqi: Int
        let name: String
    }
    let id: UUID
    let a: Location
    let b: Location
    let price: Double
    
    init(response: BookingResponse) {
        id = response.id
        a = Booking.Location(
            id: response.a.id,
            latitude: response.a.latitude,
            longitude: response.a.longitude,
            aqi: response.a.aqi,
            name: response.a.name
        )
        b = Booking.Location(
            id: response.b.id,
            latitude: response.b.latitude,
            longitude: response.b.longitude,
            aqi: response.b.aqi,
            name: response.b.name
        )
        price = response.price
        
    }
}
