//
//  ScanItem.swift
//  capstone
//
//  Created by 박영근 on 4/16/25.
//

import Foundation
import SwiftData

@Model
class ScanItem {
    var id: UUID
    var fileName: String
    var timestamp: Date
    var thumbnailPath: String? //Optional: 썸네일 이미지 저장용
    var modelFileURL: URL? //3D 파일 저장 위치
    
    init(fileName: String, timestamp: Date = Date(), thumbnailPath: String? = nil, modelFileURL: URL? = nil ) {
        self.id = UUID()
        self.fileName = fileName
        self.thumbnailPath = thumbnailPath
        self.modelFileURL = modelFileURL
        self.timestamp = timestamp
    }
}
