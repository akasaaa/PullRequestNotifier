//
//  Preferences.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct Preferences: View {

    enum PreferencesMenu: String, CaseIterable  {
        case github = "GitHub Settings"
        case local = "Local Settings"
    }

    @State var selectedMenu = PreferencesMenu.github

    var body: some View {
        VStack {
            Picker(selection: $selectedMenu, label: EmptyView(), content: {
                ForEach(PreferencesMenu.allCases, id: \.self) { menu in
                    Text(menu.rawValue)
                }
            })
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 400, height:100, alignment: .center)
            switch selectedMenu {
            case .github:
                GitHubSettings()
            case .local:
                LocalSettings()
            }

            Spacer()
        }
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
            .frame(width: 600, height: 400)
    }
}
