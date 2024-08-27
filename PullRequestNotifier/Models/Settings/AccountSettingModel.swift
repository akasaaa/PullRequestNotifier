//
//  AccountSettingModel.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import Foundation

struct AccountSettingModel: Codable {
    var createdAt = Date()
    var host = ""
    var token = ""
    var userName = ""
}

extension AccountSettingModel: Identifiable {
    var id: Date {
        createdAt
    }
}
