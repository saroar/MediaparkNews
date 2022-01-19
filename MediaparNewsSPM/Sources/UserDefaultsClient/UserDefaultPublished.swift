//
//  UserDefaultPublished.swift
//  
//
//  Created by Saroar Khandoker on 09.12.2021.
//

import Foundation
import Combine

@propertyWrapper
public struct UserDefaultPublished<Value: Codable> {

    let key: String
    let container: UserDefaults

    let publisher: CurrentValueSubject<Value, Never>

    public var projectedValue: CurrentValueSubject<Value, Never> { return publisher }

    public var wrappedValue: Value {
        get {
            publisher.value
        }
        set {
            publisher.send(newValue)
            container.setValue(try? PropertyListEncoder.propertyListEncoder.encode(newValue),
                               forKey: key)
        }
    }

    public init(_ key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.container = container

        var value = defaultValue
        if let data = container.value(forKey: key) as? Data {
            let optionalValue = try? PropertyListDecoder().decode(Value.self, from: data)
            value = optionalValue ?? defaultValue
        }

        publisher = .init(value)
    }
}

fileprivate extension PropertyListEncoder {
    static let propertyListEncoder = PropertyListEncoder()
}
