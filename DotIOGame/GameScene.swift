//
//  GameScene.swift
//  DotIOGame
//
//  Created by Ryan Anderson on 7/10/16.
//  Copyright (c) 2016 Ryan Anderson. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var prefs = (
        showJoyStick: false,
        showArrow: true
    )
    var previousTime: CFTimeInterval? = nil
    var player: PlayerCreature!
    var directionArrow: SKSpriteNode!
    let minDirectionArrowDistanceFromPlayer: CGFloat = 3, maxDirectionArrowDistanceFromPlayer: CGFloat = 200
    let spawnPosition = CGPoint(x: 200, y: 200)
    let playerSpeed: CGFloat = 100
    var playerMovingTouch: UITouch? = nil
    var originalMovingTouchPositionInCamera: CGPoint? = nil
    var joyStickBox: SKNode!, controlStick: SKNode!
    let maxControlStickDistance: CGFloat = 20
    
    override func didMoveToView(view: SKView) {
        player = PlayerCreature(name: "Yoloz Boy 123")
        player.position = spawnPosition
        player.velocity.speed = playerSpeed
        addChild(player)
        
        directionArrow = SKSpriteNode(imageNamed: "arrow.png")
        directionArrow.zPosition = 100
        directionArrow.size = CGSize(width: player.size.width/5, height: player.size.height/5)
        directionArrow.zRotation = player.velocity.angle
        directionArrow.hidden = true
        camera!.addChild(directionArrow)
        
        joyStickBox = childNodeWithName("//joyStickBox")
        controlStick = childNodeWithName("//controlStick")
        joyStickBox.hidden = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if playerMovingTouch == nil {
                playerMovingTouch = touch
                let location = touch.locationInNode(camera!)
                originalMovingTouchPositionInCamera = location
                
                if prefs.showArrow {
                    directionArrow.hidden = false
                    directionArrow.position = convertPoint(convertPoint(CGPoint(x: player.size.width + minDirectionArrowDistanceFromPlayer, y: 0), fromNode: player), toNode: camera!)
                    directionArrow.zRotation = player.velocity.angle - CGFloat(90).degreesToRadians()
                }
                
                if prefs.showJoyStick {
                    joyStickBox.position = originalMovingTouchPositionInCamera!
                    joyStickBox.hidden = false
                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if touch == playerMovingTouch {
                let location = touch.locationInNode(camera!)
                let angle = (location - originalMovingTouchPositionInCamera!).angle
                
                player.velocity.angle = angle
                
                if prefs.showArrow {
                    // My means of determining the position of the arrow:
                    // the arrow will be straight ahead of the player's eyeball. How far it is is the distance the current touch location is from its orignal position. I have a value clamp too.
                    var pointInRelationToPlayer = CGPoint(x: player.size.width + location.distanceTo(originalMovingTouchPositionInCamera!), y: 0)
                    pointInRelationToPlayer.x.clamp(player.size.width + minDirectionArrowDistanceFromPlayer, player.size.width + maxDirectionArrowDistanceFromPlayer)
                    directionArrow.position = convertPoint(convertPoint(pointInRelationToPlayer, fromNode: player), toNode: camera!)
                    directionArrow.zRotation = player.velocity.angle - CGFloat(90).degreesToRadians()
                }
                
                if prefs.showJoyStick {
                    //Move controlStick based on finger movement. Also add a distance cap
                    controlStick.position = location - originalMovingTouchPositionInCamera!
                    if location.distanceTo(originalMovingTouchPositionInCamera!) > maxControlStickDistance {
                        let angle = atan2(controlStick.position.y, controlStick.position.x)
                        controlStick.position.x = cos(angle) * maxControlStickDistance
                        controlStick.position.y = sin(angle) * maxControlStickDistance
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            if touch == playerMovingTouch {
                playerMovingTouch = nil
                originalMovingTouchPositionInCamera = nil
                if prefs.showArrow {
                    directionArrow.hidden = true
                }
                if prefs.showJoyStick {
                    joyStickBox.hidden = true
                    controlStick.position = CGPoint(x: 0, y: 0)
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        let deltaTime = currentTime - (previousTime ?? currentTime)
        previousTime = currentTime
        
        player.update(deltaTime)
        
        camera!.position = player.position
    }
}
