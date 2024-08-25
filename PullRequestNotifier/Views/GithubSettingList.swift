//
//  GithubSettingList.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct GithubSettingList: View {
    
    private let decoder = JSONDecoder()
    
    @AppStorage("repositorySettingList") private var repositorySettingList = Data()
    
    var repositories: [RepositorySetting] {
        let decoded = try? decoder.decode([RepositorySetting].self, from: repositorySettingList)
        return (decoded ?? []).sorted { $0.createdAt < $1.createdAt }
    }
    
    @State var selection: RepositorySetting.ID?
    
    @State var shouldPresentDetail = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            Table(repositories, selection: $selection) {
                TableColumn("host") { repository in
                    Text(repository.host)
                }
                TableColumn("user") { repository in
                    Text(repository.user)
                }
                TableColumn("repository") { repository in
                    Text(repository.repository)
                }
                TableColumn("labelFilter") { repository in
                    Text(repository.labelFilter)
                }
            }
            Button(selection == nil ? "追加" : "編集") {
                shouldPresentDetail = true
            }
            .padding(.init(top: 0, leading: 0, bottom: 8, trailing: 16))
        }
        .sheet(isPresented: $shouldPresentDetail) {
            let setting = repositories.first { $0.createdAt == selection }
            GitHubSettings(setting: setting)
                .frame(width: 500, height: 300)
        }
    }
}

#Preview {
    GithubSettingList()
}
