//
//  Branch.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import Foundation

struct Branch: Codable {
    let label: String?
    let ref: String?
    let sha: String?
}
