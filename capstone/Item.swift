//
//  Item.swift
//  capstone
//
//  Created by 박영근 on 4/16/25.
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
