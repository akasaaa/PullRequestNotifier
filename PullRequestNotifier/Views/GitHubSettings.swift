//
//  GitHubSettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct RepositorySetting: Codable {
    var token = ""
    var host = ""
    var user = ""
    var repository = ""
    var labelFilter = ""
}

struct GitHubSettings: View {
    
    private let encoder = JSONEncoder()
    
    @AppStorage("repositorySetting") private var repositorySetting = Data()

    @State private var token = ""

    // TODO: 複数持てるようにする
    @State private var host = ""
    @State private var user = ""
    @State private var repository = ""
    // TODO: 複数のラベルに対応させる
    @State private var labelFilter = ""

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
        .onAppear {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(RepositorySetting.self, from: repositorySetting) {
                token = decoded.token
                host = decoded.host
                user = decoded.user
                repository = decoded.repository
                labelFilter = decoded.labelFilter
            }
        }
        .onChange(of: [token, host, user, repository, labelFilter]) { _, changes in
            let setting = RepositorySetting(token: changes[0], host: changes[1], user: changes[2], repository: changes[3], labelFilter: changes[4])
            if let encoded = try? encoder.encode(setting) {
                repositorySetting = encoded
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
