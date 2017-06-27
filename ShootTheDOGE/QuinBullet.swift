//
//  quinBullet.swift
//  ShootTheDOGE
//
//  Created by csair on 2017/6/20.
//  Copyright © 2017年 harunokuma. All rights reserved.
//

import UIKit
import SceneKit

class QuinBullet:SCNNode{
    var timer:Timer!
    override init () {
        super.init()
        let sphere = SCNSphere(radius: 0.025)
        self.geometry = sphere
        self.name = "QuinBullet"
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.mass = 500
        self.physicsBody?.categoryBitMask = CollisionCategory.quinBullet.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.actor.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.diffuse.contents = UIImage(named: "galaxy")
        self.geometry?.materials  = [material]
        timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: {(Timer)->Void in
            if self.parent != nil{
                self.hit()
            }
        })
    }
    
    func hit(){
        self.removeFromParentNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
