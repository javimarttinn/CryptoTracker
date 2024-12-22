//
//  Item.swift
//  CryptoTracker
//
//  Created by Javier Martin on 22/12/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
