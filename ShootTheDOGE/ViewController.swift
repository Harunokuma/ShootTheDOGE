//
//  ViewController.swift
//  ShootTheDOGE
//
//  Created by csair on 2017/6/17.
//  Copyright © 2017年 harunokuma. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var actorHPStrip: UIProgressView!
//    let actorNode = Actor()
    private var actorHP:Int = 100{
        didSet{
            DispatchQueue.main.async {
                self.actorHPStrip.progress = Float(self.actorHP) / 100
                if self.actorHP <= 0{
                    for node in self.sceneView.scene.rootNode.childNodes{
                        if node.name?.range(of: "Monster") != nil{
                            (node as! Monster).dead(isNow: true)
                        }
                    }
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "LoseViewController")
                    self.show(vc, sender: self)
                }
            }
        }
    }
    private var score:Int = 0{
        didSet{
            DispatchQueue.main.async {
                self.scoreLabel.text = String(self.score)
                self.updateDiffculty()
            }
        }
    }
    
    var monsterSpeed : Float = 0
    
    var flushTime: TimeInterval = 0
    var generateTime : TimeInterval = 0
    var flushRate : TimeInterval = 0.1
    var generateRate : TimeInterval = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new empty scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.rootNode.name = "rootNode"
        sceneView.isPlaying = true
        
        self.actorHP = 100
        self.addActor()
        self.score = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ARSCNViewDelegate
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Session failed with error: \(error.localizedDescription)")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if flushTime == 0{
            flushTime = time
            generateTime = time
            return
        }
        
        if flushTime < time{
            updateActorPostion()
            updateMonsterDirection()
            flushTime += flushRate
        }
        
        if generateTime < time{
            DispatchQueue.main.async {
                self.addNewMonster()
            }
//            addNewMonster()
            generateTime += generateRate
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    //MARK: Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // fire bullet in direction camera is facing
        let bulletsNode = Bullet()
        
        let (direction, position) = self.getUserVector()
        bulletsNode.position = position // SceneKit/AR coordinates are in meters
        
        let bulletDirection = direction
        bulletsNode.physicsBody?.applyForce(bulletDirection, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(bulletsNode)
    }
    
    //MARK: Game Functionality
    
    func configureSession() {
        if ARWorldTrackingSessionConfiguration.isSupported { // checks if user's device supports the more precise ARWorldTrackingSessionConfiguration
            
            // equivalent to `if utsname().hasAtLeastA9()`
            // Create a session configuration
            let configuration = ARWorldTrackingSessionConfiguration()
            configuration.planeDetection = ARWorldTrackingSessionConfiguration.PlaneDetection.horizontal
            
            // Run the view's session
            sceneView.session.run(configuration)
        } else {
            // slightly less immersive AR experience due to lower end processor
            let configuration = ARSessionConfiguration()
            
            // Run the view's session
            sceneView.session.run(configuration)
        }
    }
    
    func addNewMonster() {
        let monsterNode:Monster
        if arc4random_uniform(10) < 2{
            monsterNode = MonsterQuin()
        }
        else{
            monsterNode = Monster()
        }
        let posX = floatDistanceBetween(4, and: 7)
        let posZ = floatDistanceBetween(4, and: 7)
        let (_, userPos) = getUserVector()
        monsterNode.position = SCNVector3(posX + userPos.x, userPos.y, posZ + userPos.z) // SceneKit/AR coordinates are in meters
        let actorNode = sceneView.scene.rootNode.childNode(withName: "Actor", recursively: false)
        let lookAtConstraint = SCNLookAtConstraint(target: actorNode)
        lookAtConstraint.isGimbalLockEnabled = true
        monsterNode.constraints = [lookAtConstraint]
        sceneView.scene.rootNode.addChildNode(monsterNode)
        monsterNode.firstAppearance()
    }
    
    func addActor(){
        let actorNode = Actor()
        sceneView.scene.rootNode.addChildNode(actorNode)
        updateActorPostion()
    }
    
    func removeNodeWithAnimation(_ node: SCNNode, explosion: Bool) {
        if explosion {
            let particleSystem = SCNParticleSystem(named: "explosion", inDirectory: nil)
            let systemNode = SCNNode()
            systemNode.addParticleSystem(particleSystem!)
            // place explosion where node is
            systemNode.position = node.position
            sceneView.scene.rootNode.addChildNode(systemNode)
        }
        
        // remove node
        node.removeFromParentNode()
    }
    
    func updateMonsterDirection(){
        let actorNode = sceneView.scene.rootNode.childNode(withName: "Actor", recursively: false)
        let actorPos = actorNode?.position
        let monsterNodes = sceneView.scene.rootNode.childNodes(passingTest: {(node:SCNNode, obj: UnsafeMutablePointer<ObjCBool>) -> Bool in
            if node.name == "Monster" {
                return true
            }
            else{
                return false
            }
        })
        for monsterNode in monsterNodes{
            if (monsterNode as! Monster).isDead {
                break
            }
            
            let monsterPos = monsterNode.presentation.position
            let dirction = ViewController.dirBetweenPos(from: monsterPos, to: actorPos!)
            let velocity = ViewController.multiplyVector(dirction, mulFactor: monsterSpeed)
            
            (monsterNode as! Monster).updateVelocity(velocity)
        }
    }
    
    func printVector3(_ vec: SCNVector3){
        print("x:\(vec.x)\ny:\(vec.y)\nz:\(vec.z)")
    }
    
    func updateActorPostion(){
        let (_, userPos) = getUserVector()
        let actorNode = sceneView.scene.rootNode.childNode(withName: "Actor", recursively: false)
        actorNode?.position = SCNVector3(userPos.x, userPos.y - 0.75, userPos.z)
    }
    
    func updateDiffculty(){
        var diffcultyFactor = Double(score) / 100
        if diffcultyFactor > 1{
            diffcultyFactor = 1
        }
        generateRate = 6 - diffcultyFactor * 4
        monsterSpeed = Float(0.5 + diffcultyFactor * 0.5)
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4FromMat4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    static func dirBetweenPos(from first: SCNVector3, to second: SCNVector3) -> SCNVector3{
        var dir = SCNVector3(
            second.x - first.x,
            second.y - first.y,
            second.z - first.z
        )
        let normalizedFactor = sqrt(dir.x * dir.x + dir.y * dir.y + dir.z * dir.z)
        dir.x = dir.x / normalizedFactor
        dir.y = dir.y / normalizedFactor
        dir.z = dir.z / normalizedFactor
        return dir
    }
    
    static func multiplyVector(_ vec: SCNVector3, mulFactor factor: Float) -> SCNVector3{
        return SCNVector3(Float(vec.x * sqrt(factor)), Float(vec.y * sqrt(factor)), Float(vec.z * sqrt(factor)))
    }
    
    func floatBetween(_ first: Float,  and second: Float) -> Float { // random float between upper and lower bound (inclusive)
        return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
    }
    
    func floatDistanceBetween(_ first: Float, and second: Float) -> Float{
        return (Float(arc4random_uniform(2)) * 2 - 1) * floatBetween(first, and: second)
    }
    
    // MARK: - Contact Delegate
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var actorNode: SCNNode? = nil
        var monsterNode: SCNNode? = nil
        var bulletNode: SCNNode? = nil
        var quinBulletNode: SCNNode? = nil
        
        switch contact.nodeA.physicsBody?.categoryBitMask {
        case CollisionCategory.actor.rawValue?:
            actorNode = contact.nodeA
            break
        case CollisionCategory.monster.rawValue?:
            monsterNode = contact.nodeA
            break
        case CollisionCategory.bullets.rawValue?:
            bulletNode = contact.nodeA
            break
        case CollisionCategory.quinBullet.rawValue?:
            quinBulletNode = contact.nodeA
            break
        default:
            break
        }
        
        switch contact.nodeB.physicsBody?.categoryBitMask {
        case CollisionCategory.actor.rawValue?:
            actorNode = contact.nodeB
            break
        case CollisionCategory.monster.rawValue?:
            monsterNode = contact.nodeB
            break
        case CollisionCategory.bullets.rawValue?:
            bulletNode = contact.nodeB
            break
        case CollisionCategory.quinBullet.rawValue?:
            quinBulletNode = contact.nodeB
            break
        default:
            break
        }
        
        if actorNode == nil {
            //no actor in this collision, means monster conflicts with bullet
            var isMonsterDead = false
            isMonsterDead = (monsterNode as! Monster).underAttack()
            (bulletNode as! Bullet).hit()
            if isMonsterDead{
                self.score += 10
            }
            print("hit monster")
        }
        else if quinBulletNode == nil{
            // no quinBullet in this collision, means actor conflicts with monster
            (actorNode as! Actor).underAttack()
            self.actorHP = (actorNode as! Actor).HP
            (monsterNode as! Monster).dead(isNow: true)
        }
        else if monsterNode == nil{
            // no monster in this collision, means actor conflicts with quinBullet
            (actorNode as! Actor).underAttack()
            self.actorHP = (actorNode as! Actor).HP
            (quinBulletNode as! QuinBullet).hit()
        }
    }
    
}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bullets  = CollisionCategory(rawValue: 1 << 0) // 00...001
    static let monster = CollisionCategory(rawValue: 1 << 1) // 00..010
    static let actor = CollisionCategory(rawValue: 1 << 2) // 00..100
    static let quinBullet = CollisionCategory(rawValue: 1 << 3) //00..1000
}

extension utsname {
    func hasAtLeastA9() -> Bool { // checks if device has at least A9 chip for configuration
        var systemInfo = self
        uname(&systemInfo)
        let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
            return String(cString: ptr)
        }
        switch str {
        case "iPhone8,1", "iPhone8,2", "iPhone8,4", "iPhone9,1", "iPhone9,2", "iPhone9,3", "iPhone9,4": // iphone with at least A9 processor
            return true
        case "iPad6,7", "iPad6,8", "iPad6,3", "iPad6,4", "iPad6,11", "iPad6,12": // ipad with at least A9 processor
            return true
        default:
            return false
        }
    }
}



