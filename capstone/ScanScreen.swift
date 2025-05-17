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
            ARScannerView(arView: $arView, meshEntities: $meshEntities)
                .edgesIgnoringSafeArea(.all)

            Button("스캔 저장") {
                saveScan()
            }
            .padding()
        }
    }

    private func saveScan() {
        guard let entity = meshEntities.first else { return }

        let fileName = "scan_\(UUID().uuidString.prefix(5)).usdz"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        // RealityKit 3 이상에서만 사용 가능
        entity.export(to: fileURL, completion: { result in
            switch result {
            case .success:
                ThumbnailGenerator.generateThumbnail(from: entity) { image in
                    let thumbPath = saveThumbnail(image: image)

                    let newItem = ScanItem(fileName: fileName, thumbnailPath: thumbPath, modelFileURL: fileURL)
                    DispatchQueue.main.async {
                        onScanComplete(newItem)
                        dismiss()
                    }
                }
            case .failure(let error):
                print("❌ export 실패: \(error)")
            }
        })
    }

    private func saveThumbnail(image: UIImage?) -> String? {
        guard let image = image,
              let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent("thumb_\(UUID().uuidString.prefix(4)).jpg")

        do {
            try data.write(to: path)
            return path.path
        } catch {
            print("❌ 썸네일 저장 실패: \(error)")
            return nil
        }
    }
}
