//
//  Preferences.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

var window: NSWindow?

func showPreferences() {
    window?.close()
    window = NSWindow()
    window?.styleMask.insert(.closable)
    window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
    window?.standardWindowButton(.zoomButton)?.isHidden = true
    window?.isReleasedWhenClosed = false
    window?.contentView = NSHostingView(rootView: Preferences().frame(width: 600, height: 400))
    window?.center()
    window?.makeKeyAndOrderFront(nil)
    NSApp.windows.forEach { if ($0.canBecomeMain) {$0.orderFrontRegardless() } }
}

struct Preferences: View {

    enum PreferencesMenu: String, CaseIterable  {
        case account = "Account Settings"
        case repository = "Repository Settings"
        case local = "Local Settings"
    }

    @State var selectedMenu = PreferencesMenu.account

    var body: some View {
        VStack {
            Picker(selection: $selectedMenu, label: EmptyView(), content: {
                ForEach(PreferencesMenu.allCases, id: \.self) { menu in
                    Text(menu.rawValue)
                }
            })
            .pickerStyle(SegmentedPickerStyle())
            .padding(.init(top: 16, leading: 16, bottom: 8, trailing: 16))
            switch selectedMenu {
            case .account:
                AccountSettingList()
            case .repository:
                RepositorySettingList()
            case .local:
                LocalSettings()
                    .padding(.init(top: 16, leading: 0, bottom: 0, trailing: 0))
                Spacer()
            }
            
        }
        .frame(width: 600)
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
            .frame(width: 600, height: 400)
    }
}
