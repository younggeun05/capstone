//
//  Untitled.swift
//  capstone
//
//  Created by 박영근 on 5/7/25.
//

import UIKit
import RealityKit

class ThumbnailGenerator {
    static func generateThumbnail(from entity: Entity, size: CGSize = CGSize(width: 200, height: 200), completion: @escaping (UIImage?) -> Void) {
        let arView = ARView(frame: CGRect(origin: .zero, size: size))
        let anchor = AnchorEntity()
        anchor.addChild(entity)
        arView.scene.anchors.append(anchor)

        // 렌더링 준비를 위해 약간의 지연이 필요할 수 있음
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            arView.snapshot(saveToHDR: false) { image in
                completion(image)
            }
        }
    }
}
