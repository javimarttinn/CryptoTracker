//
//  CryptoID.swift
//  CryptoTracker
//
//  Created by Javier Martin on 26/12/24.
//

import Foundation
import SwiftData

@Model
final class CryptoID: Identifiable {
    @Attribute(.unique) var id: String

    init(id: String) {
        self.id = id
    }
}
