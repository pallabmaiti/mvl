//
//  AppConfiguration.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Foundation

enum AppConfiguration {
    static var aqiApiToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "AQI_API_TOKEN") as? String else {
            preconditionFailure("Missing AQI_API_TOKEN in Info.plist build settings.")
        }

        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedToken.isEmpty else {
            preconditionFailure("AQI_API_TOKEN is empty. Set it in MVL/Config/Secrets.xcconfig.")
        }

        return trimmedToken
    }
    
    static var rgApiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "RG_API_KEY") as? String else {
            preconditionFailure("Missing RG_API_KEY in Info.plist build settings.")
        }
        
        let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKey.isEmpty else {
            preconditionFailure("RG_API_KEY is empty. Set it in MVL/Config/Secrets.xcconfig.")
        }
        
        return trimmedKey
    }
}
