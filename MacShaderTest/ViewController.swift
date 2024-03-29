//
//  ViewController.swift
//  MacShaderTest
//
//  Created by Luke Van In on 2019/11/28.
//  Copyright © 2019 eventcloud. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.allowsTransparency = false
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }
}

