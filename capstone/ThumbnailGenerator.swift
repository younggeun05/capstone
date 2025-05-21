//
//  Untitled.swift
//  capstone
//
//  Created by 박영근 on 5/7/25.
//

import UIKit
import RealityKit
import ARKit

class ThumbnailGenerator {
    static func generateThumbnail(from entity: Entity, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        let arView = ARView(frame: CGRect(origin: .zero, size: size))
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)
        
        // 비동기 스냅샷(비동기방식)
        arView.snapshot(saveToHDR: false) {
            completion(image)
        }
    }
}
