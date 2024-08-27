//
//  AccountSettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import SwiftUI

struct AccountSettings: View {

    private let initialSetting: AccountSettingModel?

    @AppStorage(AppStorageKey.accountSettingListData) private var accountSettingListData = Data()

    @State private var host = ""
    @State private var token = ""
    @State private var userName = ""

    @State private var shouldShowDestructiveAlert = false
    @State private var shouldShowInvalidParameterAlert = false

    @Environment(\.dismiss) var dismiss

    init(setting: AccountSettingModel?) {
        self.initialSetting = setting
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("host: ")
                TextField("e.g. api.github.com", text: $host)
                    .frame(width: 360)
            }
            HStack {
                Text("Personal Access Token: ")
                PasswordField("input Personal access token", text: $token)
                    .frame(width: 360)
            }
            HStack {
                Text("User Name: ")
                TextField("e.g. akasaaa", text: $userName)
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
                    if [host, token, userName].contains(where: { $0.isEmpty }) {
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
                self.host = initialSetting.host
                self.token = initialSetting.token
                self.userName = initialSetting.userName
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
            return initialSetting.host != host
                || initialSetting.token != token
                || initialSetting.userName != userName
        } else {
            return [host, token, userName].contains { !$0.isEmpty }
        }
    }

    private func save() {
        var settingList = accountSettingListData.decoded([AccountSettingModel].self) ?? []
        if let savedItemIndex = settingList.firstIndex(where: { $0.id == initialSetting?.id }) {
            var savedItem = settingList[savedItemIndex]
            savedItem.host = host
            savedItem.token = token
            savedItem.userName = userName
            settingList[savedItemIndex] = savedItem
        } else {
            var newItem = AccountSettingModel()
            newItem.host = host
            newItem.token = token
            newItem.userName = userName
            settingList.append(newItem)
        }
        accountSettingListData = settingList.encoded
    }
}

struct AccountSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettings(setting: .init(host: "api.github.com",
                                       token: "xxxxxxxxxxxxxxxxxx",
                                       userName: "akasaaa"))
            .frame(width: 600, height: 400)
    }
}
