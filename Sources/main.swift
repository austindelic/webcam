import AppKit
import AVFoundation

// A floating webcam preview. Drag to move, drag an edge to resize, Esc or Q to quit.
// Nothing is recorded or saved.

private enum Layout {
    static let size = NSSize(width: 480, height: 270)
    static let minSize = NSSize(width: 160, height: 90)
    static let screenMargin: CGFloat = 24
    static let cornerRadius: CGFloat = 14
}

private enum KeyCode {
    static let escape: UInt16 = 53
}

/// Borderless windows can't become key by default, so they'd never see Esc or Q.
final class CameraWindow: NSWindow {
    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == KeyCode.escape || event.charactersIgnoringModifiers == "q" {
            NSApp.terminate(nil)
        } else {
            super.keyDown(with: event)
        }
    }
}

/// Wraps the capture session. `AVCaptureSession` is thread-safe, and `startRunning()`
/// blocks, so it runs on its own queue instead of the main thread.
final class Camera: @unchecked Sendable {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "webcam.session")

    /// Connects the default camera. Returns false if there isn't one we can use.
    func connect() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return false }

        session.beginConfiguration()
        session.sessionPreset = .high
        session.addInput(input)
        session.commitConfiguration()
        return true
    }

    func start() {
        queue.async { self.session.startRunning() }
    }
}

/// Shows the camera feed, mirrored like a mirror, filling a rounded rectangle.
final class CameraView: NSView {
    private let camera = Camera()
    private let preview: AVCaptureVideoPreviewLayer

    override init(frame: NSRect) {
        preview = AVCaptureVideoPreviewLayer(session: camera.session)
        super.init(frame: frame)

        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.cornerRadius = Layout.cornerRadius
        layer?.masksToBounds = true

        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds
        preview.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer?.addSublayer(preview)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override var mouseDownCanMoveWindow: Bool {
        true
    }

    func start() {
        guard camera.connect() else { return }

        if let connection = preview.connection, connection.isVideoMirroringSupported {
            connection.automaticallyAdjustsVideoMirroring = false
            connection.isVideoMirrored = true
        }
        camera.start()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: CameraWindow?

    func applicationDidFinishLaunching(_: Notification) {
        let screen = NSScreen.main?.visibleFrame ?? .zero
        let origin = NSPoint(
            x: screen.maxX - Layout.size.width - Layout.screenMargin,
            y: screen.minY + Layout.screenMargin
        )

        let window = CameraWindow(
            contentRect: NSRect(origin: origin, size: Layout.size),
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentAspectRatio = Layout.size
        window.minSize = Layout.minSize

        let view = CameraView(frame: NSRect(origin: .zero, size: Layout.size))
        view.autoresizingMask = [.width, .height]
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
        self.window = window

        Task {
            if await AVCaptureDevice.requestAccess(for: .video) {
                view.start()
            } else {
                NSApp.terminate(nil)
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
        true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
