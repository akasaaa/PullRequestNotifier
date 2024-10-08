//
//  PullRequest.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import Foundation

struct PullRequest: Codable {
    let id: Int = -1
    let url: URL?
    let title: String?
    let body: String?
    let assignee: User?
    let milestone: Milestone?
    let user: User?
    let number: Int
    let labels: [Label]?
    let head: Branch?
    let base: Branch?

    var reviews = [Review]()

    enum CodingKeys: String, CodingKey {
        case id
        case url = "html_url"
        case title
        case body
        case assignee
        case milestone
        case user
        case number
        case labels
        case head
        case base
    }
}
