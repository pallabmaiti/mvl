//
//  BookingListEndpoint.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation
import Networking

struct BookingListEndpoint: ServiceEndpoint {
    struct Body: Encodable {
        let year: Int
        let month: Int
    }
    typealias SuccessResponse = [BookingResponse]
    typealias FailureResponse = GenericResponseError
    
    let body: Body?
    let method: RequestMethod = .post
    let baseURL: String = ""
    let path: String
    
    init(year: Int, month: Int) {
        path = Endpoint.bookingList.path
        body = Body(year: year, month: month)
    }
}
