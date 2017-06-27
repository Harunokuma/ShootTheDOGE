//
//  Monster.swift
//  ShootTheDOGE
//
//  Created by csair on 2017/6/17.
//  Copyright © 2017年 harunokuma. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation

class Monster: SCNNode{
    var maxHP:Int
    var HP:Int
    var isFirstUpdate:Bool = true
    var isDead:Bool = false
    var appearanceSoundEffectSourceName: String
    
    
    override init() {
        
        //monster init
        self.maxHP = 100
        self.HP = maxHP
        self.isFirstUpdate = true
        self.isDead = false
        self.appearanceSoundEffectSourceName = "surprise.mp3"
        
        super.init()
        self.name = "Monster"
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        self.geometry = box
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        self.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        self.physicsBody?.isAffectedByGravity = false
        self.physicsBody?.mass = 10
        self.physicsBody?.categoryBitMask = CollisionCategory.monster.rawValue
        self.physicsBody?.contactTestBitMask = CollisionCategory.bullets.rawValue
        
        // add texture
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "doge")
        self.geometry?.materials  = [material, material, material, material, material, material]
    }
    
    func underAttack() -> Bool{
        self.HP -= 50
        if self.HP <= 0{
            dead(isNow: false)
            return true
        }
        return false
    }
    
    func dead(isNow Now: Bool){
        if Now {
            self.removeFromParentNode()
            return
        }
        self.isDead = true
        self.physicsBody?.velocity = SCNVector3(0,0,0)
        self.physicsBody?.isAffectedByGravity = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {() in
            self.removeFromParentNode()
        })
    }
    
    func updateVelocity(_ dir : SCNVector3){
        print("Monster Velocity update!")
        self.physicsBody?.velocity = SCNVector3(dir.x,dir.y,dir.z)
    }
    
    func firstAppearance(){
        playSoundEffect(sourceName: appearanceSoundEffectSourceName)
        self.isFirstUpdate = false
    }
    
    func playSoundEffect(sourceName name: String){
        let audioSource = SCNAudioSource(named: name)
        audioSource?.volume = 0.5
        audioSource?.loops = false
        audioSource?.isPositional = true
        audioSource?.shouldStream = true
        let audioPlayer = SCNAudioPlayer(source: audioSource!)
        self.addAudioPlayer(audioPlayer)
        let play = SCNAction.playAudio(audioSource!, waitForCompletion: true)
        self.runAction(play)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
