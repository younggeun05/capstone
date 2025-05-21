//
//  ARMeshAnchor+ModelEntity.swift
//  capstone
//
//  Created by 박영근 on 5/13/25.
//

import ARKit
import RealityKit
import simd

extension ARMeshAnchor {
    func toModelEntity() -> ModelEntity? {
        let geometry = self.geometry
        
        let vertices = geometry.vertices
        let indices = geometry.faces
        
        let vertexCount = vertices.count
        var vertexArray: [SIMD3<Float>] = []
        
        for i in 0..<vertexCount {
            vertexArray.append(vertices[i])
        }
        
        var indexArray: [UInt32] = []
        let faceCount = indices.count
        for i in 0..<faceCount {
            let face = indices[i]
            indexArray.append(contentsOf: face)
        }
        
        var descriptor = MeshDescriptor()
        descriptor.positions = .init(vertexArray)
        descriptor.primitives = .triangles(indexArray)
        
        do {
            let mesh = try MeshResource.generate(from: [descriptor])
            let model = ModelEntity(mesh: mesh)
            model.generateCollisionShapes(recursive: true)
            return model
        } catch {
            print("❌ 메쉬 변환 실패: \(error)")
            return nil
        }
    }
}
