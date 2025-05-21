//
//  Untitled.swift
//  capstone
//
//  Created by 박영근 on 5/7/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ScanScreen: View {
    @Environment(\.dismiss) var dismiss
    let onScanComplete: (ScanItem) -> Void
    
    @State private var arView = ARView(frame: .zero)
    @State private var meshEntities: [ModelEntity] = []
    
    var body: some View {
        VStack {
            ARScannerView(meshEntities: $meshEntities)
                .edgesIgnoringSafeArea(.all)
            
            Button("스캔 저장") {
                saveScan()
            }
            .padding()
        }
    }
    
    private func saveScan() {
        guard let entity = meshEntities.first else { return }
        
        // 현실적인 export 기능은 없으므로 파일 경로만 생성
        let fileName = "scan_\(UUID().uuidString.prefix(5)).usdz"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            let usdzData = try entity.exportUSDZ()
            try usdzData.write(to: fileURL)
            
            let thumbImage = ThumbnailGenerator.generateThumbnail(from: entity)
            let thumbPath = saveThumbnail(image: thumbImage)
            
            let newItem = ScanItem(fileName: fileName, thumbnailPath: thumbPath, modelFileURL: fileURL)
            onScanComplete(newItem)
            dismiss()
        } catch {
            print("❌ 저장 실패: \(error)")
        }
    }
    
    private func saveThumbnail(image: UIImage?) -> String? {
        guard let image = image,
              let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let path = FileManager.default.temporaryDirectory.appendingPathComponent("thumb_\(UUID().uuidString.prefix(4)).jpg")
        
        do {
            try data.write(to: path)
            return path.path
        } catch {
            print("❌ 썸네일 저장 실패: \(error)")
            return nil
        }
    }
    
}
