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
    @Binding var arView: ARView
    @Binding var meshEntities: [ModelEntity]

    func makeUIView(context: Context) -> ARView {
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.sceneReconstruction = .meshWithClassification
        config.frameSemantics = .sceneDepth

        arView.session.delegate = context.coordinator
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(meshEntities: $meshEntities)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        @Binding var meshEntities: [ModelEntity]

        init(meshEntities: Binding<[ModelEntity]>) {
            _meshEntities = meshEntities
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let meshAnchor = anchor as? ARMeshAnchor {
                    let entity = ModelEntity(mesh: .generate(from: meshAnchor.geometry), materials: [SimpleMaterial()])
                    let anchorEntity = AnchorEntity(world: meshAnchor.transform)
                    anchorEntity.addChild(entity)
                    meshEntities.append(entity)
                }
            }
        }
    }
}
