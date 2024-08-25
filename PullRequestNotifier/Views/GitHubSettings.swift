//
//  GitHubSettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct RepositorySetting: Codable {
    var createdAt = Date()
    var token = ""
    var host = ""
    var user = ""
    var repository = ""
    var labelFilter = ""
}

extension RepositorySetting: Identifiable {
    var id: Date {
        createdAt
    }
}

struct GitHubSettings: View {

    private let initialSetting: RepositorySetting?

    @AppStorage("repositorySettingList") private var repositorySettingList = Data()

    @State private var token = ""
    @State private var host = ""
    @State private var user = ""
    @State private var repository = ""
    @State private var labelFilter = ""

    @State private var shouldShowDestructiveAlert = false
    @State private var shouldShowInvalidParameterAlert = false

    @Environment(\.dismiss) var dismiss

    init(setting: RepositorySetting?) {
        self.initialSetting = setting
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("tokens: ")
                PasswordField("input Personal access token", text: $token)
                    .frame(width: 360)
            }
            HStack {
                Text("host: ")
                TextField("e.g. api.github.com", text: $host)
                    .frame(width: 360)
            }
            HStack {
                Text("user: ")
                TextField("e.g. akasaaa", text: $user)
                    .frame(width: 360)
            }
            HStack {
                Text("repository: ")
                TextField("e.g. PullRequestNotifier", text: $repository)
                    .frame(width: 360)
            }
            HStack {
                Text("labelFilter: ")
                TextField("e.g. bug", text: $labelFilter)
                    .frame(width: 360)
            }
            HStack {
                Button("Cancel", role: .cancel) {
                    if isEditing() {
                        shouldShowDestructiveAlert = true
                    } else {
                        dismiss()
                    }
                }
                Button("Save", role: .destructive) {
                    if [token, host, user, repository].contains(where: { $0.isEmpty }) {
                        shouldShowInvalidParameterAlert = true
                    } else {
                        save()
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            if let initialSetting {
                self.token = initialSetting.token
                self.host = initialSetting.host
                self.user = initialSetting.user
                self.repository = initialSetting.repository
                self.labelFilter = initialSetting.labelFilter
            }
        }
        .alert("編集を破棄してよろしいですか？", isPresented: $shouldShowDestructiveAlert) {
            Button("No", role: .cancel) {}
            Button("Yes", role: .destructive) {
                dismiss()
            }
        }
        .alert("パラメータが不足しています", isPresented: $shouldShowInvalidParameterAlert) {}
        .frame(width: 500)
    }

    private func isEditing() -> Bool {
        if let initialSetting {
            return initialSetting.token != token
                || initialSetting.host != host
                || initialSetting.user != user
                || initialSetting.repository != repository
                || initialSetting.labelFilter != labelFilter
        } else {
            return [token, host, user, repository, labelFilter].contains { !$0.isEmpty }
        }
    }

    private func save() {
        let decoder = JSONDecoder()
        let decoded = try? decoder.decode([RepositorySetting].self, from: repositorySettingList)
        var settingList = decoded ?? []
        if let savedItemIndex = settingList.firstIndex(where: { $0.id == initialSetting?.id }) {
            var savedItem = settingList[savedItemIndex]
            savedItem.token = token
            savedItem.host = host
            savedItem.user = user
            savedItem.repository = repository
            savedItem.labelFilter = labelFilter
            settingList[savedItemIndex] = savedItem
        } else {
            var newItem = RepositorySetting()
            newItem.token = token
            newItem.host = host
            newItem.user = user
            newItem.repository = repository
            newItem.labelFilter = labelFilter
            settingList.append(newItem)
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(settingList) {
            repositorySettingList = encoded
        }
    }
}

struct GitHubSettings_Previews: PreviewProvider {
    static var previews: some View {
        GitHubSettings(setting: nil)
            .frame(width: 600, height: 400)
    }
}
