

import UIKit
import RealityKit

class ViewController: UIViewController {
  var isActionPlaying: Bool = false
  var tankAnchor: TinyToyTank._TinyToyTank?
  @IBOutlet var arView: ARView!
  
  @IBAction func tankRightPressed(_ sender: Any) {
    if self.isActionPlaying { return }
    else { self.isActionPlaying = true }
    tankAnchor!.notifications.tankRight.post()
  }
  
  @IBAction func tankForwardPressed(_ sender: Any) {
    if self.isActionPlaying { return }
    else { self.isActionPlaying = true }
    tankAnchor!.notifications.tankForward.post()
  }
  
  @IBAction func tankLeftPressed(_ sender: Any) {
    if self.isActionPlaying { return }
    else { self.isActionPlaying = true }
    tankAnchor!.notifications.tankLeft.post()
  }
  
  @IBAction func turretRightPressed(_ sender: Any) {
    if self.isActionPlaying { return }
    else { self.isActionPlaying = true }
    tankAnchor!.notifications.turretRight.post()
  }
  
  @IBAction func cannonFirePressed(_ sender: Any) {
    if self.isActionPlaying { return }
    else { self.isActionPlaying = true }
    tankAnchor!.notifications.cannonFire.post()
  }
  
  @IBAction func turretLeftPressed(_ sender: Any) {
    if self.isActionPlaying { return }
    else { self.isActionPlaying = true }
    tankAnchor!.notifications.turretLeft.post()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tankAnchor = try! TinyToyTank.load_TinyToyTank()
    tankAnchor!.turret?.setParent(tankAnchor!.tank, preservingWorldTransform: true)
    
    tankAnchor?.actions.actionComplete.onAction = { _ in
      self.isActionPlaying = false
    }
    
    arView.scene.anchors.append(tankAnchor!)
  }
}
