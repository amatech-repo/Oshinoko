//
//  GeminiAPIModel.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/12/07.
//

import Foundation

enum APIKey {
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist") else {
            fatalError("Couldn't find file 'GenerativeAI-Info.plist'. Ensure the file is added to the project and target membership.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'. Ensure the key is present in the plist file.")
        }
        if value.starts(with: "_") {
            fatalError("Invalid API key format. Follow the instructions at https://ai.google.dev/tutorials/setup to get a valid API key.")
        }
        return value
    }
}
