//
//  Review.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import Foundation

struct Review: Codable {
    let id: Int = -1
    let user: User?
    let state: String?

    enum CodingKeys: String, CodingKey {
        case id
        case user
        case state
    }
}
