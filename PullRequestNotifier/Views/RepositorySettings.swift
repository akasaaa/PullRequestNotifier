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
    @State private var displayLabels = [String]()
    @State private var displayMilestones = [String]()
    @State private var hideSelfPullRequest = true
    @State private var hideDraftPullRequest = true

    @State private var editLabels = false
    @State private var editMilestones = false

    @State private var shouldShowDestructiveAlert = false
    @State private var shouldShowInvalidParameterAlert = false

    @Environment(\.dismiss) var dismiss

    init(setting: RepositorySettingModel?) {
        self.initialSetting = setting
    }

    @State private var userName: String = ""
       @State private var password: String = ""

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("Account: ")
                Picker("", selection: $accountSettingId) {
                    ForEach(accountSettingList, id: \.id) {
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
            HStack(alignment: .top) {
                Text("表示Label: ")
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                VStack(alignment: .trailing) {
                    GroupBox {
                        switch displayLabels.count {
                        case 0:
                                Text("未設定の場合、全てのLabelが表示されます")
                                    .frame(maxWidth: .infinity)
                        case 1:
                                ForEach(displayLabels, id: \.self) { text in
                                    Text(text)
                                    if text != displayLabels.last {
                                        Divider()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                        default:
                            ScrollView {
                                ForEach(displayLabels, id: \.self) { text in
                                    Text(text)
                                    if text != displayLabels.last {
                                        Divider()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(height: 40)
                        }
                    }
                    Button("編集") {
                        editLabels = true
                    }
                }
                .frame(width: 300)

            }
            HStack(alignment: .top) {
                Text("表示Milestone: ")
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                VStack(alignment: .trailing) {
                    GroupBox {
                        switch displayMilestones.count {
                        case 0:
                                Text("未設定の場合、全てのMilestoneが表示されます")
                                    .frame(maxWidth: .infinity)
                        case 1:
                                ForEach(displayMilestones, id: \.self) { text in
                                    Text(text)
                                    if text != displayMilestones.last {
                                        Divider()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                        default:
                            ScrollView {
                                ForEach(displayMilestones, id: \.self) { text in
                                    Text(text)
                                    if text != displayMilestones.last {
                                        Divider()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(height: 40)
                        }
                    }
                    Button("編集") {
                        editMilestones = true
                    }
                }
                .frame(width: 300)

            }
            HStack {
                Text("自身のPRを非表示にする: ")
                HStack {
                    Toggle(isOn: $hideSelfPullRequest) {}
                        .toggleStyle(.switch)
                        .labelsHidden()
                    Spacer()
                }
                .frame(width: 300)
            }
            HStack {
                Text("DraftのPRを非表示にする: ")
                HStack {
                    Toggle(isOn: $hideDraftPullRequest) {}
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
                self.displayLabels = initialSetting.displayLabels
                self.displayMilestones = initialSetting.displayMilestones
                self.hideSelfPullRequest = initialSetting.hideSelfPullRequest
                self.hideDraftPullRequest = initialSetting.hideDraftPullRequest
            }
        }
        .sheet(isPresented: $editLabels) {
           TextListEditView(textList: $displayLabels)
               .frame(width: 300, height: 200)
        }

        .sheet(isPresented: $editMilestones) {
           TextListEditView(textList: $displayMilestones)
               .frame(width: 300, height: 200)
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
                || initialSetting.displayLabels != displayLabels
                || initialSetting.displayMilestones != displayMilestones
                || initialSetting.hideSelfPullRequest != hideSelfPullRequest
                || initialSetting.hideDraftPullRequest != hideDraftPullRequest
        } else {
            return accountSettingList.contains { $0.id == accountSettingId }
                || !repository.isEmpty
                || !displayLabels.isEmpty
                || !displayMilestones.isEmpty
        }
    }

    private func save() {
        var settingList = repositorySettingListData.decoded([RepositorySettingModel].self) ?? []
        if let savedItemIndex = settingList.firstIndex(where: { $0.id == initialSetting?.id }) {
            var savedItem = settingList[savedItemIndex]
            savedItem.accountSettingId = accountSettingId
            savedItem.repository = repository
            savedItem.displayLabels = displayLabels
            savedItem.displayMilestones = displayMilestones
            savedItem.hideSelfPullRequest = hideSelfPullRequest
            savedItem.hideDraftPullRequest = hideDraftPullRequest
            settingList[savedItemIndex] = savedItem
        } else {
            var newItem = RepositorySettingModel()
            newItem.accountSettingId = accountSettingId
            newItem.repository = repository
            newItem.displayLabels = displayLabels
            newItem.displayMilestones = displayMilestones
            newItem.hideSelfPullRequest = hideSelfPullRequest
            newItem.hideDraftPullRequest = hideDraftPullRequest
            settingList.append(newItem)
        }
        repositorySettingListData = settingList.encoded
    }
}

struct GitHubSettings_Previews: PreviewProvider {
    static var previews: some View {
        RepositorySettings(setting: .init(repository: "akasaaa/PullRequestNotifier", displayLabels: ["bug1", "bug2", "bug3"]))
            .frame(width: 600, height: 400)
    }
}
