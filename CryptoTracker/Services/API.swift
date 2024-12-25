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

    // Obtiene el Top 10 de criptomonedas ordenadas por capitalización de mercado
    // - Parameters:
    //   - vsCurrency: Moneda de referencia (ej. "usd", "eur")
    //   - completion: Callback con resultado exitoso o error
    
    
    func fetchTopCryptocurrencies(vsCurrency: String, completion: @escaping (Result<[Cryptocurrency], Error>) -> Void) {
        let endpoint = "coins/markets"
        let urlString = "\(baseURL)\(endpoint)?vs_currency=\(vsCurrency)&order=market_cap_desc&per_page=100&page=1"
        
         //comprobar si url valida
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(Private.coinGeckoAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        //realizar solicitud
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            //decodificar datos
            do {
                let cryptocurrencies = try JSONDecoder().decode([Cryptocurrency].self, from: data)
                completion(.success(cryptocurrencies))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    func fetchHistoricalPrices(for id: String, vsCurrency: String, days: Int, completion: @escaping (Result<[HistoricalPrice], Error>) -> Void) {
        let endpoint = "coins/\(id)/market_chart?vs_currency=\(vsCurrency)&days=\(days)&interval=daily"
        let urlString = "\(baseURL)\(endpoint)"
        
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
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let prices = json?["prices"] as? [[Any]] ?? []
                
                let historicalPrices: [HistoricalPrice] = prices.compactMap { priceEntry in
                    guard let timestamp = priceEntry[0] as? Double,
                          let price = priceEntry[1] as? Double else { return nil }
                    let date = Date(timeIntervalSince1970: timestamp / 1000)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM"
                    return HistoricalPrice(date: formatter.string(from: date), price: price)
                }
                
                completion(.success(historicalPrices))
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

