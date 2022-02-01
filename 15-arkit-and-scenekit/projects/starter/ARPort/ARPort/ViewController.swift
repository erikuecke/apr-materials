

import UIKit
import SceneKit
import ARKit

// MARK: - App State Management
enum AppState: Int16 {
    case DetectSurface
    case PointAtSurface
    case TapToStart
    case Started
}


// MARK: - UIViewController

class ViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Properties
    var trackingStatus: String = ""
    var statusMessage: String = ""
    var appState: AppState = .DetectSurface
    
    // MARK: - IB Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - IB Actions
    @IBAction func resetButtonPressed(_ sender: Any) {
        self.resetARSession()
    }
    
    @IBAction func tapGestureHandler(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initScene()
        self.initARSession()
        self.initCoachingOverlayView()
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
    
    // 1
    func startApp() {
        DispatchQueue.main.async {
            self.appState = .DetectSurface
        }
    }
    // 2
    func resetApp() {
        DispatchQueue.main.async {
            self.resetARSession()
            self.appState = .DetectSurface
        }
    }
    
}

// MARK: - AR Coaching Overlay
extension ViewController: ARCoachingOverlayViewDelegate {
    
    // 1
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
    // 2
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.startApp()
    }
    // 3
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        self.resetApp()
    }
    
    func initCoachingOverlayView() {
        // 1
        let coachingOverlay = ARCoachingOverlayView()
        // 2
        coachingOverlay.session = self.sceneView.session
        // 3
        coachingOverlay.delegate = self
        // 4
        coachingOverlay.activatesAutomatically = true
        // 5
        coachingOverlay.goal = .horizontalPlane
        // 6
        self.sceneView.addSubview(coachingOverlay)
        
        // 1
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        // 3
        NSLayoutConstraint.activate(
            [
                NSLayoutConstraint(item: coachingOverlay, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: coachingOverlay, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: coachingOverlay, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: coachingOverlay, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            ]
        )
    }
    
}

// MARK: - AR Session Management (ARSCNViewDelegate)
extension ViewController {
    
    func initARSession() {
        // 1
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        // 2
        let config = ARWorldTrackingConfiguration()
        // 3
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        config.environmentTexturing = .automatic
        // 4
        sceneView.session.run(config)
    }
    
    func resetARSession() {
        // 1
        let config = sceneView.session.configuration as! ARWorldTrackingConfiguration
        // 2
        config.planeDetection = .horizontal
        // 3
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            self.trackingStatus = "Tracking: Not available!"
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
        // 1
        let scene = SCNScene()
        sceneView.scene = scene
        // 2
        sceneView.delegate = self
    }
    
    func updateStatus() {
        // 1
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
        // 2
        self.statusLabel.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateStatus()
        }
    }
    
}

// MARK: - Focus Node Management
extension ViewController {
    
    // Add code here...
    
}
