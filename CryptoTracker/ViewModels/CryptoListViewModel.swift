//
//  CryptoListViewModel.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

// Logica e interacion con los datos
import Foundation
import Combine
import SwiftData
import SwiftUICore


struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

class CryptoListViewModel: ObservableObject {
    @Published var cryptocurrencies: [Cryptocurrency] = []
    @Published var errorMessage: ErrorMessage?
    @Published var isDataLoaded = false
    @Published var manualCryptocurrencies: [Cryptocurrency] = []
    @State private var selectedCurrency = "eur"
  //  private var modelContext: ModelContext
    
//    init(modelContext: ModelContext) {
//            self.modelContext = modelContext
 //       }
    
   
    

    func fetchTopCryptocurrencies(vsCurrency: String) {
        API.shared.fetchTopCryptocurrencies(vsCurrency: vsCurrency) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cryptos):
                    self?.cryptocurrencies = cryptos
                    self?.isDataLoaded = true
                case .failure(let error):
                    self?.errorMessage = ErrorMessage(message: error.localizedDescription)
                    self?.isDataLoaded = true
                }
            }
        }
    }
    
    @Published var searchResults: [Cryptocurrency] = []

    func searchCryptocurrency(query: String) {
        API.shared.searchCryptocurrency(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let cryptos):
                    print("✅ Resultados recibidos: \(cryptos.map { $0.name })")
                    self?.searchResults = cryptos
                case .failure(let error):
                    print("❌ Error en la búsqueda: \(error.localizedDescription)")
                    self?.errorMessage = ErrorMessage(message: error.localizedDescription)
                }
            }
        }
    }
    
    /// Añadir una criptomoneda manualmente y persistir su ID en SwiftData
    func addCryptocurrency(_ crypto: Cryptocurrency, modelContext: ModelContext) {
        // Evitar duplicados
        if !cryptocurrencies.contains(where: { $0.id == crypto.id }) {
            cryptocurrencies.append(crypto)
            
            // Guardar solo el ID en SwiftData
            let newCryptoID = CryptoID(id: crypto.id)
            modelContext.insert(newCryptoID)
            
            do {
                try modelContext.save()
                print("✅ Criptomoneda añadida y guardada correctamente: \(crypto.name)")
            } catch {
                errorMessage = ErrorMessage(message: "Error al guardar en SwiftData: \(error.localizedDescription)")
                print("❌ Error al guardar en SwiftData: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ La criptomoneda ya está en la lista.")
        }
    }
    
    func loadManualCryptocurrencies(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoID>()
        do {
            let cryptoIDs = try modelContext.fetch(fetchDescriptor)
            let group = DispatchGroup()
            var loadedCryptocurrencies: [Cryptocurrency] = []
            
            for cryptoID in cryptoIDs {
                group.enter()
                API.shared.fetchCryptocurrencyDetails(id: cryptoID.id, vsCurrency: selectedCurrency) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let crypto):
                            loadedCryptocurrencies.append(crypto)
                        case .failure(let error):
                            if let apiError = error as? APIError, apiError == .rateLimitExceeded {
                                self.errorMessage = ErrorMessage(message: "Se ha superado el límite de la API. Por favor, intenta más tarde.")
                            } else {
                                self.errorMessage = ErrorMessage(message: "Error al cargar criptomoneda \(cryptoID.id): \(error.localizedDescription)")
                            }
                        }
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.manualCryptocurrencies = loadedCryptocurrencies
                self.mergeCryptocurrencies()
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al cargar IDs persistentes: \(error.localizedDescription)")
        }
    }

    
    func mergeCryptocurrencies() {
        cryptocurrencies = Array(Set(cryptocurrencies + manualCryptocurrencies))
            .sorted { ($0.marketCap ?? 0) > ($1.marketCap ?? 0) }
    }

    
    // Eliminar una criptomoneda por su índice
    func removeCryptocurrency(at indexSet: IndexSet, modelContext: ModelContext) {
        for index in indexSet {
            let crypto = cryptocurrencies[index]
            
            // Si la criptomoneda está guardada en SwiftData, eliminar de allí
            if manualCryptocurrencies.contains(where: { $0.id == crypto.id }) {
                removeCryptocurrencyFromSwiftData(id: crypto.id, modelContext: modelContext)
            }
            
            cryptocurrencies.remove(at: index)
        }
    }

    // Eliminar una criptomoneda de SwiftData
    func removeCryptocurrencyFromSwiftData(id: String, modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<CryptoID>(predicate: #Predicate { $0.id == id })
        
        do {
            if let cryptoID = try modelContext.fetch(fetchDescriptor).first {
                modelContext.delete(cryptoID)
                try modelContext.save()
                print("✅ Criptomoneda eliminada de SwiftData: \(id)")
            }
        } catch {
            errorMessage = ErrorMessage(message: "Error al eliminar criptomoneda de SwiftData: \(error.localizedDescription)")
            print("❌ Error al eliminar criptomoneda de SwiftData: \(error.localizedDescription)")
        }
    }



    
   
    

}
