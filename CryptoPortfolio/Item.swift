//
//  Item.swift
//  CryptoPortfolio
//
//  Created by Donnadony Mollo on 31/01/26.
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
