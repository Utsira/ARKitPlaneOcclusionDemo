//
//  PlaneOccluding.swift
//  ARGraffiti
//
//  Created by Oliver Dew on 26/05/2018.
//  Copyright © 2018 saltpig. All rights reserved.
//

import ARKit
import SceneKit

protocol PlaneOccluding {
	func createOcclusionPlane(renderer: SCNSceneRenderer, anchor: ARAnchor, hasOutline: Bool) -> SCNNode?
	func updateOcclusionPlane(node: SCNNode, anchor: ARAnchor)
	func outlineColorForPlane(_ plane: ARPlaneAnchor) -> UIColor
	func outlineWidthForPlane(_ plane: ARPlaneAnchor) -> Measurement<UnitLength>
}

extension PlaneOccluding {
	func createOcclusionPlane(renderer: SCNSceneRenderer, anchor: ARAnchor, hasOutline: Bool) -> SCNNode? {
		guard let plane = anchor as? ARPlaneAnchor,
			let device = renderer.device,
			let geometry = ARSCNPlaneGeometry(device: device)
			else { return nil }
		let node = SCNNode(geometry: geometry)
		geometry.update(from: plane.geometry)
		let maskMaterial = SCNMaterial()
		// the secret sauce for occluding geometry:
		maskMaterial.colorBufferWriteMask = []
		geometry.materials = [maskMaterial]
		node.renderingOrder = -1
		if hasOutline,
			let outlineNode = outlineNodeForPlane(plane, device: device) {
			node.addChildNode(outlineNode)
		}
		return node
	}
	
	func updateOcclusionPlane(node: SCNNode, anchor: ARAnchor) {
		guard let plane = anchor as? ARPlaneAnchor,
			let geometry = node.geometry as? ARSCNPlaneGeometry
			else { return }
		geometry.update(from: plane.geometry)
		let boundingBox = planeBoundary(extent: plane.extent)
		node.boundingBox = boundingBox
		if let outlineNode = node.childNodes.first,
			let outlineGeometry = outlineNode.geometry as? ARSCNPlaneGeometry {
			outlineGeometry.update(from: plane.geometry)
			outlineNode.boundingBox = boundingBox
			outlineNode.simdScale = outlineScaleForPlane(plane)
		}
	}
	
	// SceneKit does not correctly set the bounding volume for dynamically updating geometry, causing the geometry to disappear and reappear unpredictably unless we manually update it with this method
	private func planeBoundary(extent: float3) -> (min: SCNVector3, max: SCNVector3) {
		let radius = extent * 0.5
		return (min: SCNVector3(-radius), max: SCNVector3(radius))
	}
	
	// MARK: - Plane outline
	
	private func outlineNodeForPlane(_ plane: ARPlaneAnchor, device: MTLDevice) -> SCNNode? {
		guard let outlineGeometry = ARSCNPlaneGeometry(device: device) else { return nil }
		let outlineNode = SCNNode(geometry: outlineGeometry)
		outlineGeometry.update(from: plane.geometry)
		outlineGeometry.materials = [outlineMaterialForPlane(plane)]
		outlineNode.simdScale = outlineScaleForPlane(plane)
		// place the outline 2 millimeter behind the occlusion geometry
		outlineNode.simdPosition = float3(0, -0.002, 0)
		return outlineNode
	}
	
	private func outlineMaterialForPlane(_ plane: ARPlaneAnchor) -> SCNMaterial {
		let outlineMaterial = SCNMaterial()
		outlineMaterial.lightingModel = .constant
		outlineMaterial.diffuse.contents = outlineColorForPlane(plane)
		return outlineMaterial
	}
	
	private func outlineScaleForPlane(_ plane: ARPlaneAnchor) -> float3 {
		let strokeWidth = Float(outlineWidthForPlane(plane).converted(to: .meters).value)
		return float3(1 + (strokeWidth / plane.extent.x), 1, 1 + (strokeWidth / plane.extent.z))
	}
}
