//
//  GitHubSettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct GitHubSettings: View {

    @AppStorage("token") private var token = ""

    // TODO: 複数持てるようにする
    @AppStorage("host") private var host = ""
    @AppStorage("user") private var user = ""
    @AppStorage("repository") private var repository = ""
    // TODO: 複数のラベルに対応させる
    @AppStorage("labelFilter") private var labelFilter = ""

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
        }
        .frame(width: 500)
    }
}

struct GitHubSettings_Previews: PreviewProvider {
    static var previews: some View {
        GitHubSettings()
            .frame(width: 600, height: 400)
    }
}
