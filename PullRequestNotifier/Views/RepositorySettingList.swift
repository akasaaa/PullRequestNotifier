//
//  RepositorySettingList.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct RepositorySettingList: View {

    @AppStorage(AppStorageKey.repositorySettingListData) private var repositorySettingListData = Data()

    var repositorySettingList: [RepositorySettingModel] {
        let decoded = repositorySettingListData.decoded([RepositorySettingModel].self)
        return (decoded ?? []).sorted { $0.createdAt < $1.createdAt }
    }
    
    @State var selection: RepositorySettingModel.ID?
    @State var createNewRepositorySetting = false
    @State var editRepositorySetting: RepositorySettingModel?

    var body: some View {
        VStack(alignment: .trailing) {
            Table(repositorySettingList, selection: $selection) {
                TableColumn("Repository") { repository in
                    Text(repository.repository)
                }
                TableColumn("Label Filter") { repository in
                    Text(repository.displayLabels.joined(separator: ", "))
                }
            }
            .contextMenu(
                forSelectionType: RepositorySettingModel.ID.self,
                menu: { ids in
                    Button("編集") {
                        editRepositorySetting = repositorySettingList.first { $0.id == ids.first }
                    }
                },
                primaryAction: { ids in
                    editRepositorySetting = repositorySettingList.first { $0.id == ids.first }
                })
            HStack {
                Button("追加") {
                    createNewRepositorySetting = true
                }
                Button("削除") {
                    if let index = repositorySettingList.firstIndex(where: { $0.id == selection }) {
                        var result = repositorySettingList
                        result.remove(at: index)
                        repositorySettingListData = result.encoded
                    }
                }
                .disabled(selection == nil)
            }
            .padding(.init(top: 0, leading: 0, bottom: 8, trailing: 16))
        }
        .sheet(isPresented: $createNewRepositorySetting) {
            RepositorySettings(setting: nil)
                .frame(width: 500, height: 400)
        }
        .sheet(item: $editRepositorySetting) { repositorySetting in
            RepositorySettings(setting: repositorySetting)
                .frame(width: 500, height: 400)
        }
    }
}

#Preview {
    RepositorySettingList()
}
