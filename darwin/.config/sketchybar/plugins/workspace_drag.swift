import AppKit
import Foundation

private struct SpaceItem {
    let number: Int
    let display: String
}

private final class SpaceDragMonitor {
    private var source: SpaceItem?
    private var startPoint: CGPoint?
    private var dragged = false
    private var monitor: Any?

    func run() {
        NSApplication.shared.setActivationPolicy(.prohibited)
        monitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        ) { event in
            self.handle(event)
        }
        guard monitor != nil else {
            fputs("Could not monitor mouse events. Check Input Monitoring permission.\n", stderr)
            return
        }
        RunLoop.main.run()
    }

    private func handle(_ event: NSEvent) {
        let point = mouseLocation()

        switch event.type {
        case .leftMouseDown:
            source = item(at: point)
            startPoint = source == nil ? nil : point
            dragged = false
        case .leftMouseDragged:
            if let startPoint {
                dragged = hypot(point.x - startPoint.x, point.y - startPoint.y) > 8
            }
        case .leftMouseUp:
            defer {
                source = nil
                startPoint = nil
                dragged = false
            }
            guard dragged, let source, let target = item(at: point),
                  source.display == target.display,
                  source.number != target.number else { return }
            _ = command("yabai", [
                "-m", "space", String(source.number), "--swap", String(target.number)
            ])
        default:
            break
        }
    }

    private func mouseLocation() -> CGPoint {
        let point = NSEvent.mouseLocation
        let mainHeight = NSScreen.screens.first?.frame.maxY ?? 0
        return CGPoint(x: point.x, y: mainHeight - point.y)
    }

    private func item(at point: CGPoint) -> SpaceItem? {
        let mainHeight = NSScreen.screens.first?.frame.maxY ?? 0
        let nearTopBar = NSScreen.screens.contains { screen in
            let top = mainHeight - screen.frame.maxY
            return point.x >= screen.frame.minX && point.x < screen.frame.maxX
                && point.y >= top && point.y < top + 100
        }
        guard nearTopBar else { return nil }

        guard let spaces = command("yabai", ["-m", "query", "--spaces"]),
              let spaceList = try? JSONSerialization.jsonObject(with: spaces) as? [[String: Any]] else {
            return nil
        }
        for space in spaceList {
            guard let number = space["index"] as? Int else { continue }
            guard let data = command("sketchybar", [
                "--query", "workspace.\(number)"
            ]),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let rects = object["bounding_rects"] as? [String: [String: Any]] else {
                continue
            }

            for (display, geometry) in rects {
                guard let origin = geometry["origin"] as? [NSNumber], origin.count == 2,
                      let size = geometry["size"] as? [NSNumber], size.count == 2,
                      let displayIndex = Int(display.replacingOccurrences(of: "display-", with: "")),
                      displayIndex > 0, displayIndex <= NSScreen.screens.count else {
                    continue
                }

                let screen = NSScreen.screens[displayIndex - 1]
                let screenOrigin = CGPoint(
                    x: screen.frame.minX,
                    y: mainHeight - screen.frame.maxY
                )
                let rect = CGRect(
                    x: screenOrigin.x + CGFloat(truncating: origin[0]),
                    y: screenOrigin.y + CGFloat(truncating: origin[1]),
                    width: CGFloat(truncating: size[0]),
                    height: CGFloat(truncating: size[1])
                )
                if rect.contains(point) {
                    return SpaceItem(number: number, display: display)
                }
            }
        }
        return nil
    }

    private func command(_ path: String, _ arguments: [String]) -> Data? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [path] + arguments
        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()
        do {
            try process.run()
            let data = output.fileHandleForReading.readDataToEndOfFile()
            process.waitUntilExit()
            return process.terminationStatus == 0 ? data : nil
        } catch {
            return nil
        }
    }
}

private let dragMonitor = SpaceDragMonitor()
dragMonitor.run()
