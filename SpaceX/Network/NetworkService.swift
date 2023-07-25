//
//  Network.swift
//  SpaceX
//
//  Created by Gabriel Monteiro Camargo da Silva - GCM on 16/01/22.
//

import Foundation

protocol Executor {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

class NetworkService<T: NetworkAPI> {
    
    var executor: Executor = URLSession.shared
    
    func request<V: Codable>(target: T, expecting: V.Type) async -> Result<V, NetworkError> {
        guard let url = URL(string: "\(target.baseURL)\(target.path)") else {
            return .failure(NetworkError.invalidURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.method.rawValue
        
        for header in (target.headers ?? [:]) {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        do {
            let (data, response) = try await executor.data(from: url)
            guard response.validationStatus == .success else {
                return .failure(.api(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -999,
                                     message: String(data: data, encoding: .utf8)))
            }
            let decodedResponse = try JSONDecoder().decode(expecting, from: data)
            return .success(decodedResponse)
        } catch let error as DecodingError {
            return .failure(.parse(error))
        } catch {
            return .failure(.network(error))
        }
    }
}

extension URLSession: Executor {}
