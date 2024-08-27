//
//  AppDelegate.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?

    private lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.contentViewController = NSHostingController(rootView: PullList().frame(width: 400.0))
        popover.behavior = .transient
        popover.animates = false
        return popover
    }()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.windows.forEach{ $0.close() }
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let image = NSImage(named: "octcat")
        image?.size = NSSize(width: 18, height: 18)
        statusItem?.button?.image = image
        statusItem?.button?.action = #selector(onClick)
        statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        _ = SoundEffect.systemSoundEffects
        // StatusBarのアイコン座標が取れるまで時間がかかる。とりあえず0.5s待つ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let button = self.statusItem?.button {
                self.showPopover(for: button)
            }
        }
    }

    @objc func onClick(_ sender: NSStatusBarButton) {

        guard let event = NSApp.currentEvent else {
            return
        }

        switch event.type {
        case .rightMouseUp:
            showMenu()

        case .leftMouseUp:
            showPopover(for: sender)

        default:
            break
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Preferences",
                     action: #selector(openPreferencesWindow),
                     keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit",
                     action: #selector(terminate),
                     keyEquivalent: "")
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func terminate() {
        NSApp.terminate(self)
    }
    
    @objc private func openPreferencesWindow() {
        showPreferences()
    }

    private func showPopover(for barButton: NSStatusBarButton) {
        popover.show(relativeTo: barButton.bounds, of: barButton, preferredEdge: NSRectEdge.maxY)
        popover.contentViewController?.view.window?.makeKey()
    }
}
