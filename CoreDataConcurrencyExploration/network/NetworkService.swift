//
//  NetworkService.swift
//  modulo
//
//  Created by William Dupont on 04/06/2024.
//

import Foundation

protocol NetworkService: Sendable {
    func requestData<T: Codable>(at url: String, addDelay: Bool) async throws -> T
    func sendData<T: Codable>(data: T, to url: String) async throws
}

extension NetworkService {
    func requestData<T: Codable>(at url: String, addDelay: Bool = false) async throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.invalidURL
        }
        
        if addDelay {
            sleep(2)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func sendData<T: Codable>(data: T, to url: String) async throws {
        // TODO: implement logic for sending data over the network
        print("MOCK: Data has been sent.")
    }
}
