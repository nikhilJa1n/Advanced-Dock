import Cocoa
import SwiftUI

class SwitcherWindow: NSPanel {
    private var hostingView: NSHostingView<SwitcherView>?
    private var refreshToken: UUID = UUID()
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 850, height: 260),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.level = .statusBar // Place it above regular windows and system elements
        self.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle] // Enable showing over fullscreen apps and multiple spaces
        self.ignoresMouseEvents = false // Allow mouse interactions if the user wants to click a thumbnail
    }
    
    func show(appState: AppState, windows: [WindowInfo], currentIndex: Int, scale: Double, onHover: @escaping (Int) -> Void, onClick: @escaping (Int) -> Void) {
        // New token forces all WindowCard views to reload their thumbnails
        refreshToken = UUID()
        let rootView = SwitcherView(
            appState: appState,
            windows: windows,
            currentIndex: currentIndex,
            scale: scale,
            refreshToken: refreshToken,
            onHoverIndex: onHover,
            onClickIndex: onClick
        )
        
        if let hosting = hostingView {
            hosting.rootView = rootView
        } else {
            let hosting = NSHostingView(rootView: rootView)
            self.contentView = hosting
            self.hostingView = hosting
        }
        
        // Recalculate frame to wrap around SwiftUI's intrinsic content size
        if let documentView = self.contentView {
            let fittingSize = documentView.fittingSize
            logMessage("show: fittingSize=\(fittingSize) frame before setContentSize=\(self.frame)")
            self.setContentSize(fittingSize)
            logMessage("show: frame after setContentSize=\(self.frame)")
        }
        
        self.centerOnScreen()
        self.orderFront(nil)
    }
    
    func update(appState: AppState, windows: [WindowInfo], currentIndex: Int, scale: Double, onHover: @escaping (Int) -> Void, onClick: @escaping (Int) -> Void) {
        let rootView = SwitcherView(
            appState: appState,
            windows: windows,
            currentIndex: currentIndex,
            scale: scale,
            refreshToken: refreshToken,
            onHoverIndex: onHover,
            onClickIndex: onClick
        )
        hostingView?.rootView = rootView
    }
    
    func hide() {
        self.orderOut(nil)
        WindowList.clearThumbnailCache()
    }
    
    private func centerOnScreen() {
        // Find screen with cursor, or primary screen
        let screen = NSScreen.screens.first(where: {
            NSMouseInRect(NSEvent.mouseLocation, $0.frame, false)
        }) ?? NSScreen.main ?? NSScreen.screens.first
        
        guard let targetScreen = screen else { return }
        
        let visibleFrame = targetScreen.visibleFrame
        let windowFrame = self.frame
        
        let x = visibleFrame.origin.x + (visibleFrame.width - windowFrame.width) / 2
        // Center vertically within the visible desktop area (below menu bar / notch, above dock)
        var y = visibleFrame.origin.y + (visibleFrame.height - windowFrame.height) * 0.50
        
        // Safety guard: ensure top edge of switcher never overlaps the top menu bar / notch area
        let maxY = visibleFrame.maxY - 12
        if (y + windowFrame.height) > maxY {
            y = maxY - windowFrame.height
        }
        
        // Safety guard: ensure bottom edge never goes below dock
        if y < visibleFrame.origin.y + 12 {
            y = visibleFrame.origin.y + 12
        }
        
        logMessage("centerOnScreen: visibleFrame=\(visibleFrame) windowFrame=\(windowFrame) calculatedX=\(x) calculatedY=\(y)")
        self.setFrameOrigin(NSPoint(x: x, y: y))
    }
    
    private func logMessage(_ msg: String) {
        AppLogger.log("[SwitcherWindow] \(msg)")
    }
}
