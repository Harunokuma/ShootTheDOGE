//
//  Bullut.swift
//  ARbiubiubiu
//
//  Created by csair on 2017/6/17.
//  Copyright © 2017年 harunokuma. All rights reserved.
//

import UIKit
import SceneKit

// Spheres that are shot at the "ships"
class Bullet: SCNNode {
    var timer:Timer!
    
    override init () {
        super.init()
        let sphere = SCNSphere(radius: 0.025)
        self.geometry = sphere
        self.name = "Bullet"
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        // see http://texnotes.me/post/5/ for details on collisions and bit masks
        self.physicsBody?.categoryBitMask = CollisionCategory.bullets.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.monster.rawValue
        self.physicsBody?.mass = 0.1
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "bullet_texture")
        self.geometry?.materials  = [material]
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: {(Timer)->Void in
            self.hit()
        })
    }
    
    func hit(){
//        DispatchQueue.main.async {
            self.removeFromParentNode()
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
