//
//  AccountSettingList.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import SwiftUI

struct AccountSettingList: View {

    @AppStorage(AppStorageKey.accountSettingListData) private var accountSettingListData = Data()
    @AppStorage(AppStorageKey.repositorySettingListData) private var repositorySettingListData = Data()

    var accountSettingList: [AccountSettingModel] {
        let decoded = accountSettingListData.decoded([AccountSettingModel].self)
        return (decoded ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var repositorySettingList: [RepositorySettingModel] {
        return repositorySettingListData.decoded([RepositorySettingModel].self) ?? []
    }

    @State var selection: AccountSettingModel.ID?
    @State var shouldPresentDetail = false
    @State var shouldShowDestructiveAlert = false

    var body: some View {
        VStack(alignment: .trailing) {
            Table(accountSettingList, selection: $selection) {
                TableColumn("Host") { accountSettingModel in
                    Text(accountSettingModel.host)
                }
                TableColumn("User Name") { accountSettingModel in
                    Text(accountSettingModel.userName)
                }
            }
            .contextMenu(forSelectionType: AccountSettingModel.ID.self) { ids in
                Button("編集") {
                    selection = ids.first
                    shouldPresentDetail = true
                }
            }
            HStack {
                Button("追加") {
                    shouldPresentDetail = true
                }
                Button("削除") {
                    if isUsing() {
                        shouldShowDestructiveAlert = true
                    } else {
                        delete()
                    }
                }
                .disabled(selection == nil)
            }
            .padding(.init(top: 0, leading: 0, bottom: 8, trailing: 16))
        }
        .alert("このアカウントを使用したリポジトリ設定が存在します。同時に削除されますがよろしいですか？", isPresented: $shouldShowDestructiveAlert) {
            Button("No", role: .cancel) {}
            Button("Yes", role: .destructive) {
                delete()
            }
        }
         .sheet(isPresented: $shouldPresentDetail) {
            let accountSettingModel = accountSettingList.first { $0.id == selection }
            AccountSettings(setting: accountSettingModel)
                .frame(width: 500, height: 300)
        }
    }

    private func isUsing() -> Bool {
        guard let accountSetting = accountSettingList.first(where: { $0.id == selection }) else {
            return false
        }
        return repositorySettingList.contains { $0.accountSettingId == accountSetting.id }
    }

    private func delete() {
        let filteredAccountSettingList = accountSettingList.filter { $0.id != selection }
        accountSettingListData = filteredAccountSettingList.encoded
        let filteredRepositorySettingList = repositorySettingList.filter { $0.accountSettingId != selection }
        repositorySettingListData = filteredRepositorySettingList.encoded
    }
}

#Preview {
    AccountSettingList()
}
