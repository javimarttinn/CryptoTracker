//
//  API.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//
// API.swift
import Foundation

class API {
    static let shared = API()
    private let baseURL = "https://api.coingecko.com/api/v3/"

    private init() {}

    /// Obtiene el Top 10 de criptomonedas ordenadas por capitalización de mercado
    /// - Parameters:
    ///   - vsCurrency: Moneda de referencia (ej. "usd", "eur")
    ///   - completion: Callback con resultado exitoso o error
    
    
    func fetchTopCryptocurrencies(vsCurrency: String, completion: @escaping (Result<[Cryptocurrency], Error>) -> Void) {
        let endpoint = "coins/markets"
        let urlString = "\(baseURL)\(endpoint)?vs_currency=\(vsCurrency)&order=market_cap_desc&per_page=10&page=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(Private.coinGeckoAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let cryptocurrencies = try JSONDecoder().decode([Cryptocurrency].self, from: data)
                completion(.success(cryptocurrencies))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

enum APIError: Error {
    case invalidURL
    case noData
}
