import UIKit
import ARKit
import Flutter
import SceneKit.ModelIO

class ARKitViewController: NSObject, FlutterPlatformView, ARSCNViewDelegate {
    private var sceneView: ARSCNView
    private var planeNodes: [UUID: SCNNode] = [:]
    private var channel: FlutterMethodChannel
    
    private var chairNode: SCNNode?
    private var isChairPlaced = false
    
    init(frame: CGRect, viewId: Int64, messenger: FlutterBinaryMessenger) {
        sceneView = ARSCNView(frame: frame)
        channel = FlutterMethodChannel(name: "arkit_flutter_plugin/\(viewId)", binaryMessenger: messenger)
        
        super.init()
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        
        setupMethodChannel()
    }
    
    func view() -> UIView {
        createSimpleChairModel()
        
        return sceneView
    }
    
    private func createSimpleChairModel() {
        let chairNode = SCNNode()
        
        let seatGeometry = SCNBox(width: 0.4, height: 0.05, length: 0.4, chamferRadius: 0.02)
        let seatMaterial = SCNMaterial()
        seatMaterial.diffuse.contents = UIColor.systemRed
        seatGeometry.materials = [seatMaterial]
        
        let seatNode = SCNNode(geometry: seatGeometry)
        seatNode.position = SCNVector3(0, 0.25, 0)
        chairNode.addChildNode(seatNode)
        
        let backGeometry = SCNBox(width: 0.4, height: 0.3, length: 0.05, chamferRadius: 0.02)
        let backMaterial = SCNMaterial()
        backMaterial.diffuse.contents = UIColor.systemBlue
        backGeometry.materials = [backMaterial]
        
        let backNode = SCNNode(geometry: backGeometry)
        backNode.position = SCNVector3(0, 0.4, -0.175)
        chairNode.addChildNode(backNode)
        
        let legGeometry = SCNCylinder(radius: 0.02, height: 0.25)
        let legMaterial = SCNMaterial()
        legMaterial.diffuse.contents = UIColor.systemBrown
        legGeometry.materials = [legMaterial]
        
        let legPositions = [
            SCNVector3(-0.15, 0.125, -0.15),
            SCNVector3(0.15, 0.125, -0.15),
            SCNVector3(-0.15, 0.125, 0.15),
            SCNVector3(0.15, 0.125, 0.15)
        ]
        
        for position in legPositions {
            let legNode = SCNNode(geometry: legGeometry)
            legNode.position = position
            chairNode.addChildNode(legNode)
        }
        
        self.chairNode = chairNode
        
        print("Chair model created successfully")
    }
    

    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "resetSession":
                self.resetSession()
                result(nil)
            case "addChairModel":
                self.addChairToCenter()
                result(true)
            case "removeChairModel":
                self.removeChair()
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        planeNodes.removeAll()
        
        chairNode?.removeFromParentNode()
        isChairPlaced = false
        
        print("AR session reset")
    }
    

    private func addChairToCenter() {
        let center = CGPoint(x: sceneView.bounds.midX, y: sceneView.bounds.midY)
        let hitResults = sceneView.hitTest(center, types: .existingPlaneUsingExtent)
        
        if let hitResult = hitResults.first, let chairToPlace = chairNode?.clone() {
            chairNode?.removeFromParentNode()
            
            let position = SCNVector3Make(
                hitResult.worldTransform.columns.3.x,
                hitResult.worldTransform.columns.3.y + 0.01, // Трохи підняти над площиною
                hitResult.worldTransform.columns.3.z
            )
            
            chairToPlace.position = position
            sceneView.scene.rootNode.addChildNode(chairToPlace)
            chairNode = chairToPlace
            isChairPlaced = true
            
            print("Chair placed on detected plane at position: \(position)")
            
            channel.invokeMethod("onChairPlaced", arguments: nil)
        } else {
            if let camera = sceneView.session.currentFrame?.camera, let chairToPlace = chairNode?.clone() {
                chairNode?.removeFromParentNode()
                
                var transform = camera.transform
                transform.columns.3.z -= 1.0
                
                chairToPlace.simdTransform = transform
                chairToPlace.position.y -= 0.5
                
                sceneView.scene.rootNode.addChildNode(chairToPlace)
                chairNode = chairToPlace
                isChairPlaced = true
                
                print("Chair placed in front of camera")
                
                channel.invokeMethod("onChairPlaced", arguments: nil)
            } else {
                print("Failed to place chair")
                channel.invokeMethod("onError", arguments: ["message": "Наведіть камеру на горизонтальну поверхню і спробуйте знову"])
            }
        }
    }
    
    private func removeChair() {
        chairNode?.removeFromParentNode()
        isChairPlaced = false
        
        print("Chair removed")
        
        channel.invokeMethod("onChairRemoved", arguments: nil)
    }
    

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        planeNode.eulerAngles.x = -.pi / 2
        
        if planeAnchor.alignment == .horizontal {
            planeNode.name = "horizontal"
        } else {
            planeNode.name = "vertical"
        }
        
        planeNodes[planeAnchor.identifier] = planeNode
        
        node.addChildNode(planeNode)
        
        print("Plane detected: \(planeAnchor.alignment == .horizontal ? "horizontal" : "vertical")")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
              let planeNode = planeNodes[planeAnchor.identifier],
              let plane = planeNode.geometry as? SCNPlane else { return }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
        
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        planeNodes.removeValue(forKey: planeAnchor.identifier)
        
        print("Plane removed")
    }
}

class ARKitViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return ARKitViewController(frame: frame, viewId: viewId, messenger: messenger)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
} 
