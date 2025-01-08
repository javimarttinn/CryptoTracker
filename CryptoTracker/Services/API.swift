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
        let urlString = "\(baseURL)\(endpoint)?vs_currency=\(vsCurrency)&order=market_cap_desc&per_page=10&page=1"
        
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
    
    
    
    
    
    func searchCryptocurrency(query: String, completion: @escaping (Result<[Cryptocurrency], Error>) -> Void) {
        let endpoint = "search"
        let urlString = "\(baseURL)\(endpoint)?query=\(query)"
        
        // Verificar si la URL es válida
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        // Realizar la solicitud
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
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                let cryptocurrencies = searchResult.coins.map { coin in
                    Cryptocurrency(
                        id: coin.id,
                        symbol: coin.symbol,
                        name: coin.name,
                        image: coin.large,
                        currentPrice: 0.0,
                        marketCap: 0.0,
                        marketCapRank: 0,
                        fullyDilutedValuation: 0.0,
                        totalVolume: 0.0,
                        high24h: 0.0,
                        low24h: 0.0,
                        priceChange24h: 0.0,
                        priceChangePercentage24h: 0.0,
                        marketCapChange24h: 0.0,
                        marketCapChangePercentage24h: 0.0,
                        circulatingSupply: 0.0,
                        totalSupply: 0.0,
                        maxSupply: nil,
                        ath: 0.0,
                        athChangePercentage: 0.0,
                        athDate: "",
                        atl: 0.0,
                        atlChangePercentage: 0.0,
                        atlDate: "",
                        roi: nil,
                        lastUpdated: "",
                        isFavorite: false
                    )

                }
                completion(.success(cryptocurrencies))
            } catch {
                print("❌ Error al decodificar JSON: \(error.localizedDescription)")
                completion(.failure(APIError.decodingError))
            }

        }
        task.resume()
    }


    
    
    func fetchCryptocurrencyDetails(id: String, vsCurrency: String, completion: @escaping (Result<Cryptocurrency, Error>) -> Void) {
        let endpoint = "coins/markets"
        let urlString = "\(baseURL)\(endpoint)?vs_currency=\(vsCurrency)&ids=\(id)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            // 🔍 Depurar JSON
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📊 JSON recibido para \(id): \(jsonString)")
            }
            
            do {
                // Decodificar como un array de Cryptocurrency
                let cryptocurrencies = try JSONDecoder().decode([Cryptocurrency].self, from: data)
                if let cryptocurrency = cryptocurrencies.first {
                    completion(.success(cryptocurrency))
                } else {
                    completion(.failure(APIError.noData))
                }
            } catch {
                print("❌ Error al decodificar JSON para \(id): \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }



    

    // Estructura de búsqueda para decodificar el JSON
    struct SearchResult: Codable {
        let coins: [Coin]
    }

    struct Coin: Codable {
        let id: String
        let symbol: String
        let name: String
        let large: String
    }


}

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError
    case rateLimitExceeded // ⚠️ Nuevo tipo de error
}

