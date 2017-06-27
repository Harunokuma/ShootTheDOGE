//
//  MonsterQuin.swift
//  ShootTheDOGE
//
//  Created by csair on 2017/6/20.
//  Copyright © 2017年 harunokuma. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class MonsterQuin: Monster{
    
    var attackSoundEffectSourceName = "rue.mp3"
    override init() {
        super.init()
        self.maxHP = 200
        self.HP = maxHP
        self.appearanceSoundEffectSourceName = "jingle.mp3"
        self.name = "MonsterQuin"
        let box = SCNBox(width: 0.3, height: 0.42, length: 0.3, chamferRadius: 0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .static, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionCategory.monster.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "quin")
        self.geometry?.materials  = [material, material, material, material, material, material]
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {(Timer)->Void in
            self.attack()
        })
    }
    
    override func dead(isNow Now: Bool) {
        if isDead{
            return 
        }
        self.isDead = true
        self.removeFromParentNode()
    }
    
    func attack(){
        self.shootToActor()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.shootToActor()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.shootToActor()
        })
    }
    
    func shootToActor(){
        if self.isDead{
            return
        }
        playSoundEffect(sourceName: attackSoundEffectSourceName)
        let bulletNode = QuinBullet()
        let rootNode = self.parent
        let quinPos = self.presentation.position
        var actorPos = rootNode?.childNode(withName: "Actor", recursively: false)?.position
        actorPos?.y += 0.5
        
        let dir = ViewController.dirBetweenPos(from: quinPos, to: actorPos!)
        let velocity = ViewController.multiplyVector(dir, mulFactor: 1.5)
        let moveOut = ViewController.multiplyVector(dir, mulFactor: 0.3)
        bulletNode.position = SCNVector3(quinPos.x + moveOut.x, quinPos.y + moveOut.y, quinPos.z+moveOut.z)
        rootNode?.addChildNode(bulletNode)
        bulletNode.physicsBody?.velocity = velocity
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

