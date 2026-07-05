import SwiftUI

struct DockPreviewView: View {
    let appName: String
    let windows: [WindowInfo]
    let scale: Double
    let onSelect: (WindowInfo) -> Void
    let onClose: (WindowInfo) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(windows) { window in
                DockPreviewCard(
                    window: window,
                    scale: scale,
                    onSelect: { onSelect(window) },
                    onClose: { onClose(window) }
                )
            }
        }
        .padding(10)
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}

struct DockPreviewCard: View {
    let window: WindowInfo
    let scale: Double
    let onSelect: () -> Void
    let onClose: () -> Void
    
    @State private var thumbnail: NSImage?
    @State private var isHovered = false
    
    var body: some View {
        let cardWidth = 160.0 * scale
        let cardHeight = 100.0 * scale
        
        VStack(spacing: 6) {
            ZStack {
                // Thumbnail container
                ZStack {
                    Color.black.opacity(0.3)
                    
                    if let img = thumbnail {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: cardWidth - 8, maxHeight: cardHeight - 8)
                    } else {
                        // Fallback icon
                        if let icon = window.appIcon {
                            Image(nsImage: icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .opacity(0.3)
                        } else {
                            Image(systemName: "window.rectangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white.opacity(0.2))
                        }
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(Color.white.opacity(0.04))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHovered ? Color.blue.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1.5)
                )
                
                // Close button overlay on hover
                if isHovered {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: onClose) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Color.red.opacity(0.8))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(4)
                        }
                        Spacer()
                    }
                }
            }
            .onHover { hover in
                withAnimation(.easeOut(duration: 0.15)) {
                    isHovered = hover
                }
            }
            .onTapGesture {
                onSelect()
            }
            
            // Window title text
            Text(window.title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(isHovered ? 1.0 : 0.75))
                .lineLimit(1)
                .frame(width: cardWidth)
        }
        .onAppear {
            loadThumbnail()
        }
        .onChange(of: window.id) { _ in
            thumbnail = nil
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        DispatchQueue.global(qos: .userInteractive).async {
            if let cgImage = WindowList.getThumbnail(for: window.id) {
                let size = NSSize(width: cgImage.width, height: cgImage.height)
                let nsImage = NSImage(cgImage: cgImage, size: size)
                DispatchQueue.main.async {
                    self.thumbnail = nsImage
                }
            }
        }
    }
}
