//
//  ViewController.swift
//  PictureHangingDemo
//
//  Created by Oliver Dew on 15/06/2018.
//  Copyright © 2018 SaltPig. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    private let pictureNode = SCNScene(named: "art.scnassets/scene.scn")!.rootNode.childNodes.first!
	private var didFinishLoading = false
	
	// MARK: - View lifecycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
		scene.lightingEnvironment.contents = #imageLiteral(resourceName: "PaperMill_E_Env")
        sceneView.scene = scene
		sceneView.prepare([pictureNode]) {
			[weak self] didSucceed in
			self?.didFinishLoading = didSucceed
		}
		pictureNode.simdScale = float3(0.002)
		let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		sceneView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
	private func resetTracking() {
		sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
		let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = [.vertical, .horizontal]
		sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
	}
	
	// MARK: - Gestures
	
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		guard motion == .motionShake else { return }
		resetTracking()
	}
	
	@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
		let point = gesture.location(in: gesture.view)
		guard didFinishLoading,
			let arResult = sceneView.hitTest(point, types: .existingPlaneUsingExtent).first,
			let anchor = arResult.anchor,
			let node = sceneView.node(for: anchor) else { return }
		node.addChildNode(pictureNode)
	}
}

// MARK: - PlaneOccluding

extension ViewController: PlaneOccluding {
	func outlineColorForPlane(_ plane: ARPlaneAnchor) -> UIColor {
		let color = abs(plane.transform.up)
		return UIColor(red: CGFloat(color.x), green: CGFloat(color.y), blue: CGFloat(color.z), alpha: 0.8)
	}
	
	func outlineWidthForPlane(_ plane: ARPlaneAnchor) -> Measurement<UnitLength> {
		return Measurement(value: 5, unit: UnitLength.millimeters)
	}
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
		return createOcclusionPlane(renderer: renderer, anchor: anchor, hasOutline: true)
    }
	
	func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
		updateOcclusionPlane(node: node, anchor: anchor)
	}

	func session(_ session: ARSession, didFailWithError error: Error) {
		// Present an error message to the user
		
	}
	
	func sessionWasInterrupted(_ session: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay
		
	}
	
	func sessionInterruptionEnded(_ session: ARSession) {
		resetTracking()
	}

}
