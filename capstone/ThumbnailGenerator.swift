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
        
        // 비동기 스냅샷(비동기 방식)
        var thumbnailImage: UIImage?
        let semaphore = DispatchSemaphore(value: 0) // 비동기 처리를 위한 세마포어
        
        arView.snapshot(saveToHDR: false) { image in
            thumbnailImage = image
            semaphore.signal() // 스냅샷 완료 시 세마포어 신호
        }
        
        semaphore.wait() // 스냅샷이 완료될 때까지 대기
        return thumbnailImage // 생성된 이미지 반환
    }
}
