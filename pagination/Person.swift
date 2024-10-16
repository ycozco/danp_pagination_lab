// Person.swift

import Foundation

struct Results: Codable {
    let results: [Person]
    let info: Info
}

struct Person: Identifiable, Codable {
    var id: String { login.uuid }
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob: DOB
    let phone: String
    let cell: String
    let picture: Picture
    let nat: String
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: Postcode
    let coordinates: Coordinates
    let timezone: Timezone
    
    // Propiedad calculada para obtener el código postal como String
    var postcodeString: String {
        switch postcode {
        case .int(let value):
            return String(value)
        case .string(let value):
            return value
        }
    }
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable {
    let offset: String
    let description: String
}

struct Login: Codable {
    let uuid: String
}

struct DOB: Codable {
    let date: String
    let age: Int
}

struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}

struct Info: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

// Manejo de código postal que puede ser Int o String
enum Postcode: Codable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intPostcode = try? container.decode(Int.self) {
            self = .int(intPostcode)
        } else if let stringPostcode = try? container.decode(String.self) {
            self = .string(stringPostcode)
        } else {
            throw DecodingError.typeMismatch(Postcode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "El tipo de Postcode no coincide"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let intPostcode):
            try container.encode(intPostcode)
        case .string(let stringPostcode):
            try container.encode(stringPostcode)
        }
    }
}
