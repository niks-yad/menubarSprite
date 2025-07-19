import Cocoa
import CoreGraphics

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem!
    var spriteImages: [NSImage] = []
    var currentFrame = 0
    var animationTimer: Timer?
    var mouseTrackingTimer: Timer?
    var lastMousePosition: CGPoint = CGPoint.zero
    var isAnimating = false
    
    // Animation directions
    enum Direction: CaseIterable {
        case up, down, left, right, idle
    }
    
    var currentDirection: Direction = .down
    var lastDirection: Direction = .down
    
    // Enlarged sprite window
    var enlargedWindow: NSWindow?
    var enlargedImageView: NSImageView?
    var isEnlargedViewOpen = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Make this a menu bar-only app
        NSApp.setActivationPolicy(.accessory)
        
        // Close any default windows
        for window in NSApp.windows {
            window.close()
        }
        
        setupMenuBar()
        loadSpriteFrames()
        setupMouseTracking()
        setStaticFrame()
    }
    
    func setupMenuBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "person.fill", accessibilityDescription: "Sprite")
            button.image?.size = NSSize(width: 32, height: 32)
            button.action = #selector(statusBarButtonClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp])
        }
        
        // Right-click menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Enlarged View", action: #selector(statusBarButtonClicked), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu
    }
    
    func loadSpriteFrames() {
        guard let spriteSheetPath = Bundle.main.path(forResource: "sprite_sheet", ofType: "png"),
              let spriteSheet = NSImage(contentsOfFile: spriteSheetPath) else {
            print("Error: Could not load sprite_sheet.png - make sure it's added to your Xcode project")
            return
        }
        
        // Extract frames from 4x4 grid
        let frameWidth = spriteSheet.size.width / 4
        let frameHeight = spriteSheet.size.height / 4
        spriteImages.removeAll()
        
        for row in 0..<4 {
            for col in 0..<4 {
                let frameImage = NSImage(size: NSSize(width: frameWidth, height: frameHeight))
                frameImage.lockFocus()
                
                let sourceRect = NSRect(
                    x: CGFloat(col) * frameWidth,
                    y: spriteSheet.size.height - CGFloat(row + 1) * frameHeight,
                    width: frameWidth,
                    height: frameHeight
                )
                
                spriteSheet.draw(in: NSRect(origin: .zero, size: frameImage.size),
                               from: sourceRect,
                               operation: .copy,
                               fraction: 1.0)
                frameImage.unlockFocus()
                
                // Resize for menu bar
                let menuBarFrame = NSImage(size: NSSize(width: 32, height: 32))
                menuBarFrame.lockFocus()
                frameImage.draw(in: NSRect(origin: .zero, size: menuBarFrame.size))
                menuBarFrame.unlockFocus()
                
                spriteImages.append(menuBarFrame)
            }
        }
    }
    
    func setupMouseTracking() {
        lastMousePosition = NSEvent.mouseLocation
        
        mouseTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkMouseMovement()
        }
    }
    
    func checkMouseMovement() {
        let currentMousePosition = NSEvent.mouseLocation
        let deltaX = currentMousePosition.x - lastMousePosition.x
        let deltaY = currentMousePosition.y - lastMousePosition.y
        let threshold: CGFloat = 10.0
        
        var newDirection: Direction = .idle
        
        if abs(deltaY) > threshold && abs(deltaY) > abs(deltaX) {
            newDirection = deltaY > 0 ? .up : .down
        } else if abs(deltaX) > threshold {
            newDirection = deltaX > 0 ? .right : .left
        }
        
        if newDirection != .idle {
            lastDirection = newDirection
            animateInDirection(newDirection)
        }
        
        lastMousePosition = currentMousePosition
    }
    
    func animateInDirection(_ direction: Direction) {
        if isAnimating && currentDirection == direction {
            return
        }
        
        currentDirection = direction
        isAnimating = true
        animationTimer?.invalidate()
        startDirectionalAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.stopDirectionalAnimation()
        }
    }
    
    func startDirectionalAnimation() {
        currentFrame = getStartingFrameForDirection(currentDirection)
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            self?.updateDirectionalFrame()
        }
    }
    
    func stopDirectionalAnimation() {
        isAnimating = false
        animationTimer?.invalidate()
        setStaticFrameForDirection(lastDirection)
    }
    
    func setStaticFrame() {
        currentFrame = getStartingFrameForDirection(.down)
        updateMenuBarIcon()
    }
    
    func setStaticFrameForDirection(_ direction: Direction) {
        currentFrame = getStartingFrameForDirection(direction)
        updateMenuBarIcon()
    }
    
    func getStartingFrameForDirection(_ direction: Direction) -> Int {
        // Sprite layout: Row 1: Down (0-3), Row 2: Left (4-7), Row 3: Right (8-11), Row 4: Up (12-15)
        switch direction {
        case .down: return 0
        case .left: return 4
        case .right: return 8
        case .up: return 12
        case .idle: return 0
        }
    }
    
    func updateDirectionalFrame() {
        let startFrame = getStartingFrameForDirection(currentDirection)
        let frameInSequence = (currentFrame - startFrame + 1) % 4
        currentFrame = startFrame + frameInSequence
        updateMenuBarIcon()
    }
    
    func updateMenuBarIcon() {
        guard currentFrame < spriteImages.count,
              let button = statusBarItem.button else { return }
        
        DispatchQueue.main.async {
            button.image = self.spriteImages[self.currentFrame]
            
            if self.isEnlargedViewOpen, let imageView = self.enlargedImageView {
                let enlargedImage = self.createEnlargedImage(from: self.spriteImages[self.currentFrame])
                imageView.image = enlargedImage
            }
        }
    }
    
    @objc func statusBarButtonClicked() {
        if isEnlargedViewOpen {
            closeEnlargedView()
        } else {
            openEnlargedView()
        }
    }
    
    func openEnlargedView() {
        guard !isEnlargedViewOpen else { return }
        
        let windowSize = NSSize(width: 300, height: 300)
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let windowFrame = NSRect(
            x: screenFrame.midX - windowSize.width / 2,
            y: screenFrame.midY - windowSize.height / 2,
            width: windowSize.width,
            height: windowSize.height
        )
        
        enlargedWindow = NSWindow(
            contentRect: windowFrame,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        enlargedWindow?.title = "Sprite Follower"
        enlargedWindow?.backgroundColor = NSColor.controlBackgroundColor
        enlargedWindow?.isReleasedWhenClosed = false
        enlargedWindow?.delegate = self
        
        enlargedImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 128, height: 128))
        enlargedImageView?.imageScaling = .scaleProportionallyUpOrDown
        enlargedImageView?.translatesAutoresizingMaskIntoConstraints = false
        
        if currentFrame < spriteImages.count {
            let enlargedImage = createEnlargedImage(from: spriteImages[currentFrame])
            enlargedImageView?.image = enlargedImage
        }
        
        if let contentView = enlargedWindow?.contentView, let imageView = enlargedImageView {
            contentView.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 128),
                imageView.heightAnchor.constraint(equalToConstant: 128)
            ])
        }
        
        enlargedWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        isEnlargedViewOpen = true
    }
    
    func closeEnlargedView() {
        enlargedWindow?.close()
        enlargedWindow = nil
        enlargedImageView = nil
        isEnlargedViewOpen = false
    }
    
    func createEnlargedImage(from smallImage: NSImage) -> NSImage {
        let enlargedSize = NSSize(width: 128, height: 128)
        let enlargedImage = NSImage(size: enlargedSize)
        
        enlargedImage.lockFocus()
        smallImage.draw(in: NSRect(origin: .zero, size: enlargedSize))
        enlargedImage.unlockFocus()
        
        return enlargedImage
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        animationTimer?.invalidate()
        mouseTrackingTimer?.invalidate()
        closeEnlargedView()
    }
}

// MARK: - NSWindowDelegate
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow == enlargedWindow {
            isEnlargedViewOpen = false
            enlargedWindow = nil
            enlargedImageView = nil
        }
    }
}
