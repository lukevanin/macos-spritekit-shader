//
//  GameScene.swift
//  MacShaderTest
//
//  Created by Luke Van In on 2019/11/28.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var shaderNode: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        let shaderNode = makeShaderNode()
        addChild(shaderNode)
        self.shaderNode = shaderNode
    }
    
    private func makeShaderNode() -> SKSpriteNode {
        
        let sprite = SKSpriteNode(
            color: .magenta,
            size: CGSize(
                width: self.size.width,
                height: self.size.height
            )
        )
        sprite.blendMode = .replace
        
//        let shader = SKShader(fileNamed: "mandelbrot.fsh")
        let shader = SKShader(fileNamed: "raymarching.fsh")
        sprite.shader = shader
        
        let spriteSize = vector_float2(
            x: Float(sprite.frame.size.width),
            y: Float(sprite.frame.size.height)
        )
        
        let offset = vector_float2(
            x: 0,
            y: 0
        )
//        let offset = vector_float2(
//            x: -7.0 / 4.0,
//            y: 0
//        )
        let scale = vector_float2(
            x: 1.0,
            y: spriteSize.y / spriteSize.x
        )
        
        shader.uniforms = [
            SKUniform(name: "u_offset", vectorFloat2: offset),
            SKUniform(name: "u_scale", vectorFloat2: scale),
        ]
        
        return sprite
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
