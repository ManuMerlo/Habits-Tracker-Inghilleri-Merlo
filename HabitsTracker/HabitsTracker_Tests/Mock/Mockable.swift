//
//  Mockable.swift
//  HabitsTracker_Tests
//
//  Created by Manuela Merlo on 25/08/23.
//

import Foundation

protocol Mockable: AnyObject {
    
}


extension Mockable {
    var bundle: Bundle{
        return Bundle(for: type(of: self))
    }
    
    func loadJSON <T: Decodable> (filename: String, type: T.Type) -> [T]{
        guard let path = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON file.")
        }
        do {
            let data = try Data(contentsOf: path)
            let decodedObject = try JSONDecoder().decode([T].self, from: data)
            return decodedObject
        }
        catch{
            fatalError("Failed to decode JSON")
        }
    }
    
}
