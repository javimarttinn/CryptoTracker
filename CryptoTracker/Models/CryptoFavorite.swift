//
//  CryptoPersistente.swift
//  CryptoTracker
//
//  Created by Javier Martin on 25/12/24.
//

import SwiftData

@Model
class CryptoFavorite {
    @Attribute(.unique) var id: String
    
    init(id: String) {
        self.id = id
    }
}
