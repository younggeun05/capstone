//
//  Untitled.swift
//  capstone
//
//  Created by 박영근 on 5/7/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARScannerView: UIViewRepresentable {
    func makeUIView(context: ContentView) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Scene Reconstruction 설정
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .mesh
        config.frameSemantics = .sceneDepth
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // delegate 설정
        arView.session.delegate = context.coordinator
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: ContentView) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    // MARK: - Coordinator collects mesh data
    class Coordinator: NSObject, ARSessionDelegate {
        private var collectedAnchors: [ARMeshAnchor] = []
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    collectedAnchors.append(meshAnchor)
                }
            }
        }
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    collectedAnchors.append(meshAnchor)
                }
            }
        }
        
        // 저장 트리거용 메서드
        func exportMesh(to url: URL) {
            // 여기에 Reality Composer Pro 또는 USDExporter로 변환 로직이 필요함
            // Apple의 Model I/O 또는 RealityKit 3에서 `Entity` → usdz 가능.
            print("⚠️ 구현 필요: ARMeshAnchor를 usdz 또는 reality 파일로 저장")
        }
    }
        
}

