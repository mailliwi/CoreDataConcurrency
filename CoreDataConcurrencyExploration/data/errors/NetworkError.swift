//
//  NetworkError.swift
//  CoreDataExploration
//
//  Created by William Dupont on 13/05/2024.
//

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case other
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .invalidURL:
            "Invalid URL"
        case .invalidResponse:
            "Invalid Response"
        case .decodingError:
            "Decoding Error"
        case .other:
            "Undefined"
        }
    }
    
    var description: String {
        switch self {
        case .invalidURL:
            "The URL for the data being requested is invalid."
        case .invalidResponse:
            "The response was invalid."
        case .decodingError:
            "The response could not be decoded."
        case .other:
            "Undefined error. Contact developer."
        }
    }
}
