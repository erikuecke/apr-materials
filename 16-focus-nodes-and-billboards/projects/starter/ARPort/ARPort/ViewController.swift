

import UIKit
import SceneKit
import ARKit

// MARK: - App State Management

enum AppState: Int16 {
    case DetectSurface  // Scan surface (Plane Detection On)
    case PointAtSurface // Point at surface to see focus point (Plane Detection Off)
    case TapToStart     // Focus point visible on surface, tap to start
    case Started
}

// MARK: - UIViewController

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var statusMessage: String = ""
    var appState: AppState = .DetectSurface
    var focusPoint: CGPoint!
    var focusNode: SCNNode!
    
    
    // MARK: - IB Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - IB Actions
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetApp()
    }
    
    @IBAction func tapGestureHandler(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initScene()
        self.initCoachingOverlayView()
        self.initARSession()
        self.initFocusNode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("*** ViewWillAppear()")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("*** ViewWillDisappear()")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("*** DidReceiveMemoryWarning()")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - App Management

extension ViewController {
    
    func startApp() {
        DispatchQueue.main.async {
            self.appState = .DetectSurface
        }
    }
    
    func resetApp() {
        DispatchQueue.main.async {
            self.resetARSession()
            self.appState = .DetectSurface
        }
    }
}

// MARK: - AR Coaching Overlay

extension ViewController : ARCoachingOverlayViewDelegate {
    
    func initCoachingOverlayView() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = self.sceneView.session
        coachingOverlay.delegate = self
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
        self.sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item:  coachingOverlay, attribute: .top, relatedBy: .equal,
                               toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item:  coachingOverlay, attribute: .bottom, relatedBy: .equal,
                               toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item:  coachingOverlay, attribute: .leading, relatedBy: .equal,
                               toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item:  coachingOverlay, attribute: .trailing, relatedBy: .equal,
                               toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        ])
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.startApp()
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        self.resetApp()
    }
}

// MARK: - AR Session Management (ARSCNViewDelegate)

extension ViewController {
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        sceneView.session.run(config)
    }
    
    func resetARSession() {
        let config = sceneView.session.configuration as!
        ARWorldTrackingConfiguration
        config.planeDetection = .horizontal
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            self.trackingStatus = "Tracking:  Not available!"
        case .normal:
            self.trackingStatus = ""
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                self.trackingStatus = "Tracking: Limited due to excessive motion!"
            case .insufficientFeatures:
                self.trackingStatus = "Tracking: Limited due to insufficient features!"
            case .relocalizing:
                self.trackingStatus = "Tracking: Relocalizing..."
            case .initializing:
                self.trackingStatus = "Tracking: Initializing..."
            @unknown default:
                self.trackingStatus = "Tracking: Unknown..."
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        self.trackingStatus = "AR Session Failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        self.trackingStatus = "AR Session Was Interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        self.trackingStatus = "AR Session Interruption Ended"
    }
}

// MARK: - Scene Management

extension ViewController {
    
    func initScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateStatus()
            self.updateFocusNode()
        }
    }
    
    func updateStatus() {
        switch appState {
        case .DetectSurface:
            statusMessage = "Scan available flat surfaces..."
        case .PointAtSurface:
            statusMessage = "Point at designated surface first!"
        case .TapToStart:
            statusMessage = "Tap to start."
        case .Started:
            statusMessage = "Tap objects for more info."
        }
        
        self.statusLabel.text = trackingStatus != "" ?
        "\(trackingStatus)" : "\(statusMessage)"
    }
}

// MARK: - Focus Node Management
extension ViewController {
    
    func initFocusNode() {
        
        // 1
        let focusScene = SCNScene(named: "art.scnassets/Scenes/FocusScene.scn")!
        // 2
        focusNode = focusScene.rootNode.childNode(withName: "Focus", recursively: false)!
        // 3
        focusNode.isHidden = true
        sceneView.scene.rootNode.addChildNode(focusNode)
        
        
        focusPoint = CGPoint(x: view.center.x, y: view.center.y + view.center.y * 0.1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func orientationChanged() {
        focusPoint = CGPoint(x: view.center.x , y: view.center.y  + view.center.y * 0.1)
    }
    
    func updateFocusNode() {
        // 1
        guard appState != .Started else {
            focusNode.isHidden = true
            return
        }
        // 2
        if let query = self.sceneView.raycastQuery(from: self.focusPoint, allowing: .estimatedPlane, alignment: .horizontal) {
            // 3
            let results = self.sceneView.session.raycast(query)
            if results.count == 1 {
                if let match = results.first {
                    // 4
                    let t = match.worldTransform
                    // 5
                    self.focusNode.position = SCNVector3(t.columns.3.x, t.columns.3.y, t.columns.3.z)
                    self.appState = .TapToStart
                    focusNode.isHidden = false
                }
            } else {
                // 6
                self.appState = .PointAtSurface
                focusNode.isHidden = true
            }
        }
    }
    
}
