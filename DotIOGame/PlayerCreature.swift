//
//  Player.swift
//  DotIOGame
//
//  Created by Ryan Anderson on 7/10/16.
//  Copyright © 2016 Ryan Anderson. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerCreature: SKSpriteNode, BoundByCircle {
    
    
    var normalSpeed: CGFloat = 100
    var boostingSpeed: CGFloat { return normalSpeed * 2 } //The multiplier is a constant to be played with
    var currentSpeed: CGFloat = 100 {
        didSet { velocity.speed = currentSpeed }
    }
    var isBoosting = false
    
    let playerMaxAngleChangePerSecond: CGFloat = 180
    
    var playerTargetAngle: CGFloat! //Should operate in degrees 0 to 360
    
    var radius: CGFloat = 50 {
        didSet {
            size.width = 2*radius
            size.height = 2*radius
            zPosition = radius/10 //Big creatures eat up smaller ones in terms of zPosition
        }
    }
    var prevRadius: CGFloat = 50 // TEMPorary variable
    
    var targetRadius: CGFloat = 50 //This is here so the player can grow the SMOOOOTH way
    
    var velocity: (speed: CGFloat, angle: CGFloat) = (
        speed: 0,
        angle: 0
        ) {
        
        didSet {
            //I want velocity.angle to operate in degrees from 0 to 360
            if velocity.angle > 360 {
                velocity.angle = velocity.angle % 360
            } else if velocity.angle < 0 {
                velocity.angle += 360
            }
            
            // Change positionDeltas to match
            let desiredDx = cos(velocity.angle.degreesToRadians()) * velocity.speed
            let desiredDy = sin(velocity.angle.degreesToRadians()) * velocity.speed
            
            // Only set the position deltas if they have not been set yet (avoiding recursion)
            if positionDeltas.dx != desiredDx {positionDeltas.dx = desiredDx}
            if positionDeltas.dy != desiredDy {positionDeltas.dy = desiredDy}
            
            zRotation = velocity.angle.degreesToRadians()
            
            //print(zRotation)
        }
        
    }
    
    
    var positionDeltas: (dx: CGFloat, dy: CGFloat) = (
        dx: 0,
        dy: 0
    )
    
    init(name: String) {
        let texture = SKTexture.init(imageNamed: "red circle.png") //placeholderTexture
        let color = SKColor.whiteColor()
        let size = CGSize(width: 2*radius, height: 2*radius)
        super.init(texture: texture, color: color, size: size)
        
        defer { //This keyword ensures that the didSet code is called
            velocity.speed = currentSpeed
            targetRadius = 50
            radius = 50
        }
        playerTargetAngle = velocity.angle

    }
    
    /* You are required to implement this for your subclass to work */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func update(deltaTime: CFTimeInterval) {
        position.x += positionDeltas.dx * CGFloat(deltaTime)
        position.y += positionDeltas.dy * CGFloat(deltaTime)
        
        // The player's current angle approaches its target angle
        let myAngle = velocity.angle
        let targetAngle = playerTargetAngle
        var posDist: CGFloat, negDist: CGFloat
        if targetAngle > myAngle {
            posDist = targetAngle - myAngle
            negDist = myAngle + 360 - targetAngle
        } else if targetAngle < myAngle {
            negDist = myAngle - targetAngle
            posDist = 360 - myAngle + targetAngle
        } else {
            negDist = 0
            posDist = 0
        }
        
        var deltaAngle: CGFloat
        if posDist < negDist {
            // Since the positive distance is less than the negative distance, the player will be turned the positive way. The /10's are for smoothness
            deltaAngle = posDist / 10
        } else if negDist < posDist {
            // Since the negative way is shorter, the player will turn the negative way. Again /10 allows smoothness
            deltaAngle = -negDist / 10
        } else {
            //No turning made
            deltaAngle = 0
        }
        
        // cap with slew rate
        // find the max angle change for this frame based on deltaTime
        // and ensure delta angle is no greater
        let maxAngleChangeThisFrame = playerMaxAngleChangePerSecond * CGFloat(deltaTime)
        deltaAngle.clamp(-maxAngleChangeThisFrame, maxAngleChangeThisFrame)

        velocity.angle += deltaAngle
        
        //Before having the radius approach the target radius, apply the passive size loss to target radius
        if !(radius <= 80) { targetRadius -= passiveSizeLoss * CGFloat(deltaTime) }
        
        //Approach targetRadius. So the player can grow the SMOOOOOTH way
        let deltaRadius = targetRadius - radius
        radius += deltaRadius / 10
        
        // Change the speeds if necessary
        if isBoosting { currentSpeed = boostingSpeed }
        else { currentSpeed = normalSpeed }
        
        print("Radius: \(radius)") //size cap should be about at 350 player starts at 50
        print ("Growth/sec: \((radius - prevRadius) / CGFloat(deltaTime))")
        print("\n")
        prevRadius = radius

    }
    
    var passiveSizeLoss: CGFloat {
        return CGFloat(pow(2, (radius - 50) / 75)) / 10
    }
    
    func startBoost() {
        isBoosting = true
        blendMode = SKBlendMode.Add
    }
    
    func stopBoost() {
        isBoosting = false
        blendMode = SKBlendMode.Alpha
    }
    
    
}
