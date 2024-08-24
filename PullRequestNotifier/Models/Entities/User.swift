//
//  User.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import Foundation

struct User: Codable {
    let id: Int = -1
    let avatarURL: String?
    let login: String?

    enum CodingKeys: String, CodingKey {
        case id
        case avatarURL = "avatar_url"
        case login
    }
}
