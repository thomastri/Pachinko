//
//  GameScene.swift
//  Pachinko!
//
//  Created by Thomas Le on 2/6/16.
//  Copyright (c) 2016 Thomas Le. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        
        physicsWorld.contactDelegate = self
        
        makeSlotAt(CGPoint(x: 128, y: 100), isGood: true)
        makeSlotAt(CGPoint(x: 384, y: 100), isGood: false)
        makeSlotAt(CGPoint(x: 640, y: 100), isGood: true)
        makeSlotAt(CGPoint(x: 896, y: 100), isGood: false)
        
        makeBouncerAt(CGPoint(x: 0, y: 100))
        makeBouncerAt(CGPoint(x: 256, y: 100))
        makeBouncerAt(CGPoint(x: 512, y: 100))
        makeBouncerAt(CGPoint(x: 768, y: 100))
        makeBouncerAt(CGPoint(x: 1024, y: 100))
        
        scoreLabel = SKLabelNode(fontNamed: "ChalkDuster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .Right
        scoreLabel.position = CGPoint(x: 980, y: 600)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "ChalkDuster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 600)
        addChild(editLabel)
    }
    
    func makeBouncerAt(position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask
        bouncer.physicsBody!.dynamic = false
        addChild(bouncer)
    }
    
    func makeSlotAt(position: CGPoint, isGood: Bool) {
        var slotGlow: SKSpriteNode
        var slotBase: SKSpriteNode
        
        if isGood {
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotBase.name = "good"
        } else {
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotBase.name = "bad"
        }
        
        slotGlow.position = position
        slotBase.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOfSize: slotBase.size)
        slotBase.physicsBody!.dynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        
        let spin = SKAction.rotateByAngle(CGFloat(M_PI_2), duration: 10)
        let spinForever = SKAction.repeatActionForever(spin)
        slotGlow.runAction(spinForever)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if let touch = touches.first {
            let location = touch.locationInNode(self)
            
            let objects = nodesAtPoint(location) as [SKNode]
            
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOfSize: box.size)
                    box.physicsBody!.dynamic = false
                    
                    addChild(box)
                }/Users/maestro/Documents/Pachinko!
                else {
                    let ball = SKSpriteNode(imageNamed: "ballRed")
                    ball.name = "ball"
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.restitution = 0.4
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.position = location
                    addChild(ball)
                }
            }
        }
    }
    
    func collisionBetweenBall(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroyBall(ball)
            score += 1
        } else if object.name == "bad" {
            destroyBall(ball)
            score -= 1
        }
    }
    
    func destroyBall(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.node!.name == "ball" {
            collisionBetweenBall(contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node!.name == "ball" {
            collisionBetweenBall(contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
