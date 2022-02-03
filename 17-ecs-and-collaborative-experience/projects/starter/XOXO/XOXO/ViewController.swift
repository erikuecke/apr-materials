/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RealityKit
import ARKit
import MultipeerConnectivity

class ViewController: UIViewController, ARSessionDelegate {
    
    // MARK: - Properties
    var playerColor = UIColor.blue
    var gridModelEntityX: ModelEntity?
    var gridModelEntityY: ModelEntity?
    var tileModelEntity: ModelEntity?
    
    
    // MARK: - IBOutlets & IBActions
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var message: UILabel!
    
    @IBAction func player1ButtonPressed(_ sender: Any) {
        playerColor = UIColor.blue
    }
    
    @IBAction func player2ButtonPressed(_ sender: Any) {
        playerColor = UIColor.red
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
    }
    
    // MARK: - AR View Functions
    
    func initARView() {
        arView.session.delegate = self
        arView.automaticallyConfigureSession = false
        let arConfiguration = ARWorldTrackingConfiguration()
        arConfiguration.planeDetection = [.horizontal]
        arConfiguration.environmentTexturing = .automatic
        arView.session.run(arConfiguration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initARView()
        initModelEntities()
        initGestures()
    }
}

// MARK: - Model Entity Functions

extension ViewController {
    
    func initModelEntities() {
        // 1
        gridModelEntityX = ModelEntity(mesh: .generateBox(size: SIMD3(x: 0.3, y: 0.01, z: 0.01)), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        // 2
        gridModelEntityY = ModelEntity(mesh: .generateBox(size: SIMD3(x: 0.01, y: 0.01, z: 0.3)), materials: [SimpleMaterial(color: .white, isMetallic: false)])
        // 3
        tileModelEntity = ModelEntity(mesh: .generateBox(size: SIMD3(x: 0.07, y: 0.01, z: 0.07)), materials: [SimpleMaterial(color: .gray, isMetallic: false)])
        // 4
        tileModelEntity!.generateCollisionShapes(recursive: false)
    }
    
    func cloneModelEntity(_ modelEntity: ModelEntity, position: SIMD3<Float>) -> ModelEntity {
        let newModelEntity = modelEntity.clone(recursive: false)
        newModelEntity.position = position
        return newModelEntity
    }
    
    func addGameBoardAnchor(transform: simd_float4x4) {
        // 1
        let arAnchor = ARAnchor(name: "XOXO Grid", transform: transform)
        let anchorEntity = AnchorEntity(anchor: arAnchor)
        // 2
        anchorEntity.addChild(cloneModelEntity(gridModelEntityY!, position: SIMD3(x: 0.05, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(gridModelEntityY!, position: SIMD3(x: -0.05, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(gridModelEntityX!, position: SIMD3(x: 0, y: 0, z: 0.5)))
        anchorEntity.addChild(cloneModelEntity(gridModelEntityX!, position: SIMD3(x: 0.05, y: 0, z: -0.5)))
        
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: -0.1, y: 0, z: -0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: 0, y: 0, z: -0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: 0.1, y: 0, z: -0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: -0.1, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: 0, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: 0.1, y: 0, z: 0)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: -0.1, y: 0, z: 0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: 0, y: 0, z: 0.1)))
        anchorEntity.addChild(cloneModelEntity(tileModelEntity!,
          position: SIMD3(x: 0.1, y: 0, z: 0.1)))

        // 1
        anchorEntity.anchoring = AnchoringComponent(arAnchor)
        // 2
        arView.scene.addAnchor(anchorEntity)
        arView.session.add(anchor: arAnchor)
        
    }
}

// MARK: - Gesture Functions

extension ViewController {
    
    func initGestures() {
        // 1
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer?) {
        
    }
    
}


// MARK: - Multipeer Session Functions

extension ViewController {
    
    // Add code here...
    
}

// MARK: - Helper Functions

extension ViewController {
    
    func sendMessage(_ message: String) {
        DispatchQueue.main.async {
            self.message.text = message
        }
    }
    
}



