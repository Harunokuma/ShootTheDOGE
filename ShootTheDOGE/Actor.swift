//
//  Actor.swift
//  ShootTheDOGE
//
//  Created by csair on 2017/6/17.
//  Copyright © 2017年 harunokuma. All rights reserved.
//

import UIKit
import SceneKit

class Actor: SCNNode {
    let maxHP = 100
    var HP:Int
    
    override init() {
        self.HP = maxHP
        super.init()
        
        self.name = "Actor"
        let cylinder = SCNCylinder(radius: 0.15, height: 1)
        self.geometry = cylinder
        let shape = SCNPhysicsShape(geometry: cylinder, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        
        self.physicsBody?.categoryBitMask = CollisionCategory.actor.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.monster.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.transparencyMode = SCNTransparencyMode.rgbZero;
        self.geometry?.materials  = [material, material, material]
    }
    
    func underAttack(){
        print("you're under attack!")
        self.HP -= 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
