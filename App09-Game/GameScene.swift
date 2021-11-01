//
//  GameScene.swift
//  App09-Game
//
//  Created by Alumno on 01/11/21.
//

import SwiftUI
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let plane = SKSpriteNode(imageNamed: "plane")
    var planeTouched = false
    var started = false
    var timer: Timer?
    @Binding var currentScore: Int!
    
    //paste inits and required init declarations
    init(_ name: Binding<String>, _score: Binding<Int>){
        _currentName = name
        _currentScore = score
        super.init(size: CGSize(width: 844, height: 390))
        self.scaleMode = .fill
    }
    
    required init?(coder aDecoder: NSCoder) {
        _currentName = .constant("Jorge")
        _currentScore = .constant(0)
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        
        //        let background = SKSpriteNode(imageNamed: "sky")
        //        background.size = CGSize(width: 926, height: 444)
        //        background.zPosition = 0
        //        addChild(background)
        
        plane.zPosition = 5 //just different than 0
        plane.position = CGPoint(x: -400, y: 0)
        plane.scale(to: CGSize(width: 50, height: 50))
        plane.name = "plane"
        addChild(plane)
        
        plane.physicsBody = SKPhysicsBody(texture: plane.texture!, size: CGSize(width: 50, height: 50))
        plane.physicsBody?.categoryBitMask = 1
        plane.physicsBody?.collisionBitMask = 0
        
        plane.physicsBody?.affectedByGravity = false
        physicsWorld.gravity = CGVector(dx: 0, dy: -2)
        
        parallaxScroll(image: "sky", y: 0, z: 0, duration: 6, needsPhysics: false)
        parallaxScroll(image: "ground", y: -200, z: 5, duration: 6, needsPhysics: true)
        
        physicsWorld.contactDelegate = self
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        if tappedNodes.contains(plane){
            print("Plane touched")
            planeTouched = true
        }
        if !started{ //initializes game when first touch is done
            started = true
            plane.physicsBody?.affectedByGravity = true
        }else{
            plane.physicsBody?.velocity = CGVector(dx: 0, dy: 200)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard planeTouched else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        plane.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        planeTouched = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if started{
            if plane.position.y > 180{
                plane.position.y = 180
            }
            let value = plane.physicsBody!.velocity.dy * 0.001
            let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
            plane.run(rotate)
        }
    }
    
    func parallaxScroll(image: String, y: CGFloat, z: CGFloat, duration: Double, needsPhysics: Bool) {
        
        for i in 0 ... 1 {
            let node = SKSpriteNode(imageNamed: image)
            
            node.position = CGPoint(x: 1024 * CGFloat(i), y: y)
            //                    node.size = CGSize(width: 926, height: 444)
            node.zPosition = z
            addChild(node)
            
            if needsPhysics {
                node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.texture!.size())
                node.physicsBody?.isDynamic = false
                node.physicsBody?.contactTestBitMask = 1
                
                node.name = "obstacle"
            }
            
            let move = SKAction.moveBy(x: -1024, y: 0, duration: duration)
            let wrap = SKAction.moveBy(x: 1024, y: 0, duration: 0)
            
            let sequence = SKAction.sequence([move, wrap])
            let forever = SKAction.repeatForever(sequence)
            node.run(forever)
            
        }
        
    }
    func planeHit(_ node: SKNode){
        if  node.name == "obstacle"{
            if let explosion = SKEmitterNode(fileNamed: "PlaneExplosion"){
                explosion.position = plane.position
                explosion.zPosition = 10
                addChild(explosion)
            }
            
            //run(SKAction.playSoundFileNamed("explosion", waitForCompletion: false))
            plane.removeFromParent()
            //            music.removeFromParent()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                print("hola")
                let scene = GameScene()
                scene.scaleMode = .aspectFit
                scene.size = CGSize(width: 926, height: 444)
                scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                self.view?.presentScene(scene)
            }
            
        } else{
            if node.name == "score"{
                node.removeFromParent()
                currentScore += 1
                print(currentScore)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == plane {
            planeHit(nodeB)
        }else{
            planeHit(nodeA)
        }
    }
    
    @objc func createObstacle() {
        let obstacle = SKSpriteNode(imageNamed: "asteroid")
        obstacle.zPosition = 5
        obstacle.position.x = 700
        obstacle.scale(to: CGSize(width: 50, height: 50))
        addChild(obstacle)
        
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: CGSize(width: 50, height: 50))
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = 1
        obstacle.physicsBody?.linearDamping = 0
        obstacle.name = "obstacle"
        
        let rand = GKRandomDistribution(lowestValue: -230, highestValue: 280)
        obstacle.position.y = CGFloat(rand.nextInt())
        
        let move = SKAction.moveTo(x: -780, duration: 9)
        let remove = SKAction.removeFromParent()
        let action = SKAction.sequence([move, remove])
        obstacle.run(action)
        
        
        //Increases the score by creating an invisible object that collides to incoming obstacles
        
        let collision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 20, height: 444))
        collision.physicsBody = SKPhysicsBody(rectangleOf: collision.size)
        collision.physicsBody?.contactTestBitMask = 1
        collision.physicsBody?.isDynamic = false
        collision.position.x = obstacle.frame.maxX
        collision.name = "score"
        addChild(collision)
        collision.run(action)
    }
}
