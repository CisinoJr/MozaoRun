//
//  GameScene.swift
//  MozaoRun Shared
//
//  Created by Cisino Junior on 11/02/23.
//

import SpriteKit

class GameScene: SKScene {
	
	var ground: SKSpriteNode!
	var player: SKSpriteNode!
	var obstacles:[SKSpriteNode] = []
	var coin: SKSpriteNode!
	var cameraNode = SKCameraNode()
	
	var cameraMovePointPerSecond: CGFloat = 450.0
	
	var lastUpdateTime: TimeInterval = 0.0
	var dt: TimeInterval = 0.0
	var isTime: CGFloat = 3.0
	var onGround = true
	var velocityY: CGFloat = 0.0
	var gravity: CGFloat = 0.6
	var playerPosY: CGFloat = 0.0
	
	var playableRect: CGRect {
		let ratio: CGFloat
		
		switch UIScreen.main.nativeBounds.height {
			case 2688, 1792, 2436:
				ratio = 2.16
			default:
				ratio = 16/9
		}
		
		let playableHeight = size.width / ratio
		let playableMargin = (size.height - playableHeight) / 2.0

		return CGRect(x: 0.0, y: playableMargin, width: size.width, height: playableHeight)
	}
	
	var cameraRect: CGRect {
		let width = playableRect.width
		let height = playableRect.height
		let x = cameraNode.position.x - size.width / 2.0 + (size.width - width) / 2.0
		let y = cameraNode.position.y - size.height / 2.0 + (size.height - height) / 2.0
		return CGRect(x: x, y: y, width: width, height: height)
	}
	
	override func didMove(to view: SKView) {
		setupNodes()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		if !isPaused {
			if onGround {
				onGround = false
				velocityY = -25.0
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		if velocityY < -12.5 {
			velocityY = -12.5
		}
	}

	override func update(_ currentTime: TimeInterval) {
		if lastUpdateTime > 0 {
			dt = currentTime - lastUpdateTime
		} else {
			dt = 0
		}
		
		lastUpdateTime = currentTime
		moveCamera()
		movePlayer()
		
		velocityY += gravity
		player.position.y -= velocityY
		
		if player.position.y < playerPosY {
			player.position.y = playerPosY
			velocityY = 0.0
			onGround = true 
		}
	}
            
}

extension GameScene {
	
	func setupNodes() {
		createBackground()
		createGround()
		createPlayer()
		setupObstables()
		spawnObstacles()
		setupCoin()
		spawnCoins()
		setupPhysics()
		setupCameraNode()
	}
	
	func setupPhysics() {
		physicsWorld.contactDelegate = self
	}
	
	func createBackground() {
		for i in 0...2 {
			let background = SKSpriteNode(imageNamed: "background")
			background.name = "Background"
			background.anchorPoint = .zero
			background.position = CGPoint(x: CGFloat(i)*background.frame.width, y: 0.0)
			background.zPosition = -1.0
			addChild(background)
		}
	}
	
	func createGround() {
		for i in 0...2 {
			ground = SKSpriteNode(imageNamed: "ground")
			ground.name = "Ground"
			ground.anchorPoint = .zero
			ground.zPosition = 1.0
			ground.position = CGPoint(x: CGFloat(i)*ground.frame.width, y: 0.0)
			ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
			ground.physicsBody!.isDynamic = false
			ground.physicsBody!.affectedByGravity = false
			ground.physicsBody!.categoryBitMask = PhysicsCategory.Ground
			addChild(ground)
		}
	}
	
	func createPlayer() {
		player = SKSpriteNode(imageNamed: "love")
		player.name = "Player"
		player.setScale(0.85)
		player.zPosition = 5.0
		player.position = CGPoint(x: frame.width/2.0 - 100.0,
								  y: ground.frame.height + player.frame.height/2.0)
		player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2.0)
		player.physicsBody!.affectedByGravity = false
		player.physicsBody!.restitution = 0.0
		player.physicsBody!.categoryBitMask = PhysicsCategory.Player
		player.physicsBody!.contactTestBitMask = PhysicsCategory.Block | PhysicsCategory.Obstacle | PhysicsCategory.Coin
		playerPosY = player.position.y
		
		addChild(player)
	}
	
	func setupCameraNode() {
		addChild(cameraNode)
		camera = cameraNode
		cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)
	}
	
	func moveCamera() {
		let amountToMove = CGPoint(x: cameraMovePointPerSecond * CGFloat(dt), y: 0.0 )
		cameraNode.position += amountToMove
		
		// Background
		enumerateChildNodes(withName: "Background") { (node, _) in
			let node = node as! SKSpriteNode
			
			if node.position.x + node.frame.width < self.cameraRect.origin.x {
				node.position = CGPoint(x: node.position.x + node.frame.width * 2.0,
										y: node.position.y)
			}
		}
		
		// Ground
		enumerateChildNodes(withName: "Ground") { (node, _) in
			let node = node as! SKSpriteNode
			
			if node.position.x + node.frame.width < self.cameraRect.origin.x {
				node.position = CGPoint(x: node.position.x + node.frame.width * 2.0,
										y: node.position.y)
			}
		}
	}
	
	func movePlayer() {
		let amountToMove = cameraMovePointPerSecond * CGFloat(dt)
		let rotate = CGFloat(1).degreesToRadians() * amountToMove / 2.5
		player.zRotation -= rotate
		player.position.x += amountToMove
	}
	
	func setupObstables() {
		for i in 1...3 {
			let sprite = SKSpriteNode(imageNamed: "block-\(i)")
			sprite.name = "Block"
			obstacles.append(sprite)
		}
		
		for i in 1...2 {
			let sprite = SKSpriteNode(imageNamed: "obstacle-\(i)")
			sprite.name = "Obstable"
			obstacles.append(sprite)
		}
		
		let index = Int(arc4random_uniform(UInt32(obstacles.count-1)))
		let sprite = obstacles[index].copy() as! SKSpriteNode
		sprite.zPosition = 5.0
		sprite.setScale(0.85)
		sprite.position = CGPoint(x: cameraRect.maxX + sprite.frame.width/2.0,
								  y: ground.frame.height + sprite.frame.height/2.0)
		
		sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
		sprite.physicsBody!.affectedByGravity = false
		sprite.physicsBody!.isDynamic = false
		
		if sprite.name == "Block" {
			sprite.physicsBody!.categoryBitMask = PhysicsCategory.Block
		} else {
			sprite.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
		}
		
		sprite.physicsBody!.contactTestBitMask = PhysicsCategory.Player
		
		addChild(sprite)
		sprite.run(.sequence([
			.wait(forDuration: 10.0),
			.removeFromParent()
		]))
	}
	
	func spawnObstacles() {
		let random =  Double(CGFloat.random(min: 1.5, max: isTime))
		run(.repeatForever(.sequence([
			.wait(forDuration: random),
			.run {[weak self] in
				self?.setupObstables()
			}
		])))
		
		run(.repeatForever(.sequence([
			.wait(forDuration: 5.0),
			.run {
				self.isTime -= 0.01
				
				if self.isTime <= 1.5 {
					self.isTime = 1.5
				}
			}
		])))
	}
	
	func setupCoin() {
		coin = SKSpriteNode(imageNamed: "coin-1")
		coin.name = "Coin"
		coin.zPosition = 20.0
		coin.setScale(0.85)
		let coinHeight = coin.frame.height
		let random = CGFloat.random(min: -coinHeight, max: coinHeight*2.0)
		coin.position = CGPoint(x: cameraRect.maxX + coin.frame.width, y: size.height/2.0+random)
		coin.physicsBody = SKPhysicsBody(circleOfRadius: coin.size.width / 2.0)
		coin.physicsBody!.affectedByGravity = false
		coin.physicsBody!.isDynamic = false
		coin.physicsBody!.categoryBitMask = PhysicsCategory.Coin
		coin.physicsBody!.contactTestBitMask = PhysicsCategory.Player
		
		addChild(coin)
		
		coin.run(.sequence([
			.wait(forDuration: 15.0),
			.removeFromParent()
		]))
		
		var textures: [SKTexture] = []
		
		for i in 1...6 {
			textures.append(SKTexture(imageNamed: "coin-\(i)"))
		}
		
		coin.run(.repeatForever(.animate(with: textures, timePerFrame: 0.083)))
	}
	
	func spawnCoins() {
		let random =  Double(CGFloat.random(min: 2.5, max: 6.0))
		run(.repeatForever(.sequence([
			.wait(forDuration: random),
			.run {[weak self] in
				self?.setupCoin()
			}
		])))
	}
}

extension GameScene: SKPhysicsContactDelegate {
	 
	func didBegin(_ contact: SKPhysicsContact) {
		let other = contact.bodyA.categoryBitMask == PhysicsCategory.Player ? contact.bodyB : contact.bodyA
		 
		switch other.categoryBitMask {
			case PhysicsCategory.Block:
				print("Block")
			case PhysicsCategory.Obstacle:
				print("Obstacle")
			case PhysicsCategory.Coin:
				print("Coin")
			default: break
		}
	}
}
