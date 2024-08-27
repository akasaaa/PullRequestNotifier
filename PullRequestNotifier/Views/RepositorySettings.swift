//
//  RepositorySettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct RepositorySettings: View {

    private let initialSetting: RepositorySettingModel?

    @AppStorage(AppStorageKey.repositorySettingListData) private var repositorySettingListData = Data()
    @AppStorage(AppStorageKey.accountSettingListData) private var accountSettingListData = Data()

    private var accountSettingList: [AccountSettingModel] {
        accountSettingListData.decoded([AccountSettingModel].self) ?? []
    }

    @State private var accountSettingId = AccountSettingModel.ID()
    @State private var repository = ""
    @State private var labelFilter = ""
    @State private var showSelf = true
    @State private var showApprove = true

    @State private var shouldShowDestructiveAlert = false
    @State private var shouldShowInvalidParameterAlert = false

    @Environment(\.dismiss) var dismiss

    init(setting: RepositorySettingModel?) {
        self.initialSetting = setting
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("Account: ")
                Picker("", selection: $accountSettingId) {
                    ForEach(accountSettingList, id: \.createdAt) {
                        Text("\($0.userName)(\($0.host))").tag($0.id)
                    }
                }
                .labelsHidden()
                .frame(width: 300)
            }
            HStack {
                Text("Repository: ")
                TextField("e.g. akasaaa/PullRequestNotifier", text: $repository)
                    .frame(width: 300)
            }
            HStack {
                Text("Label Filter: ")
                TextField("e.g. bug", text: $labelFilter)
                    .frame(width: 300)
            }
            HStack {
                Text("show self pull request: ")
                HStack {
                    Toggle(isOn: $showSelf) {}
                        .toggleStyle(.switch)
                        .labelsHidden()
                    Spacer()
                }
                .frame(width: 300)
            }
            HStack {
                Text("show approving pull request: ")
                HStack {
                    Toggle(isOn: $showApprove) {}
                        .toggleStyle(.switch)
                        .labelsHidden()
                    Spacer()
                }
                .frame(width: 300)
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
                    if repository.isEmpty {
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
                self.accountSettingId = initialSetting.accountSettingId
                self.repository = initialSetting.repository
                self.labelFilter = initialSetting.labelFilter
                self.showSelf = initialSetting.showSelf
                self.showApprove = initialSetting.showApprove
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
            return initialSetting.accountSettingId != accountSettingId
                || initialSetting.repository != repository
                || initialSetting.labelFilter != labelFilter
                || initialSetting.showSelf != showSelf
                || initialSetting.showApprove != showApprove
        } else {
            return !accountSettingList.contains { $0.id == accountSettingId }
                || [repository, labelFilter].contains { !$0.isEmpty }
        }
    }

    private func save() {
        var settingList = repositorySettingListData.decoded([RepositorySettingModel].self) ?? []
        if let savedItemIndex = settingList.firstIndex(where: { $0.id == initialSetting?.id }) {
            var savedItem = settingList[savedItemIndex]
            savedItem.accountSettingId = accountSettingId
            savedItem.repository = repository
            savedItem.labelFilter = labelFilter
            savedItem.showSelf = showSelf
            savedItem.showApprove = showApprove
            settingList[savedItemIndex] = savedItem
        } else {
            var newItem = RepositorySettingModel()
            newItem.accountSettingId = accountSettingId
            newItem.repository = repository
            newItem.labelFilter = labelFilter
            newItem.showSelf = showSelf
            newItem.showApprove = showApprove
            settingList.append(newItem)
        }
        repositorySettingListData = settingList.encoded
    }
}

struct GitHubSettings_Previews: PreviewProvider {
    static var previews: some View {
        RepositorySettings(setting: .init(repository: "akasaaa/PullRequestNotifier", labelFilter: "bug"))
            .frame(width: 600, height: 400)
    }
}
