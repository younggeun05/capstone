//
//  ARScannerView\.swift
//  capstone
//
//  Created by 박영근 on 5/7/25.
//

import SwiftUI
import RealityKit
import ARKit

struct ARScannerView: UIViewRepresentable {
    @Binding var meshEntities: [ModelEntity]

    func makeCoordinator() -> Coordinator {
        Coordinator(meshEntities: $meshEntities)
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .meshWithClassification
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        arView.session.delegate = context.coordinator
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var meshEntities: [ModelEntity]

        init(meshEntities: Binding<[ModelEntity]>) {
            _meshEntities = meshEntities
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            process(anchors: anchors)
        }

        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            process(anchors: anchors)
        }

        private func process(anchors: [ARAnchor]) {
            for anchor in anchors {
                guard let meshAnchor = anchor as? ARMeshAnchor else { continue }

                let entity = meshAnchor.toModelEntity()
                meshEntities.append(entity)
            }
        }
    }
}

struct TestMeshView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // ARWorldTracking + SceneReconstruction 설정
        let config = ARWorldTrackingConfiguration()
        config.sceneReconstruction = .mesh
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        // Session Delegate 설정
        arView.session.delegate = context.coordinator
        context.coordinator.arView = arView

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    let entity = meshAnchor.toModelEntity()
                    let anchorEntity = AnchorEntity(world: meshAnchor.transform)
                    anchorEntity.addChild(entity)
                    arView?.scene.anchors.append(anchorEntity)
                }
            }
        }
    }
}

