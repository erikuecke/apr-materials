

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {
  
  @IBOutlet var sceneView: ARSKView!
  @IBOutlet weak var hudLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and node count
    sceneView.showsFPS = true
    sceneView.showsNodeCount = true
    
    // Load the SKScene from 'Scene.sks'
    if let scene = SKScene(fileNamed: "Scene") {
      sceneView.presentScene(scene)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    
    // Run the view's session
    sceneView.session.run(configuration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  // MARK: - ARSKViewDelegate
  
  func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
    // Create and configure a node for the anchor added to the view's session.
    let spawnNode = SKNode()
    spawnNode.name = "SpawnPoint"
    let boxNode = SKLabelNode(text: "🆘")
    boxNode.verticalAlignmentMode = .center
    boxNode.horizontalAlignmentMode = .center
    boxNode.zPosition = 100
    boxNode.setScale(0)
    spawnNode.addChild(boxNode)
      let startSoundAction = SKAction.playSoundFileNamed("SoundEffects/GameStart.wav", waitForCompletion: false)
      let scaleInAction = SKAction.scale(to: 1.5, duration: 0.8)
      boxNode.run(SKAction.sequence([startSoundAction, scaleInAction]))
    return spawnNode
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    showAlert("Session Failure", error.localizedDescription)
  }
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .normal: break
    case .notAvailable:
      showAlert("Tracking Limited", "AR not available")
      break
    case .limited(let reason):
      switch reason {
      case .initializing, .relocalizing: break
      case .excessiveMotion:
        showAlert("Tracking Limited", "Excessive motion!")
        break
      case .insufficientFeatures:
        showAlert("Tracking Limited", "Insufficient features!")
        break
      default: break
      }
    }
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    showAlert("AR Session", "Session was interrupted!")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    let scene = sceneView.scene as! Scene
    scene.startGame()
  }
  
  func showAlert(_ title: String, _ message: String) {
    let alert = UIAlertController(title: title, message: message,
      preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
      style: UIAlertAction.Style.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}
