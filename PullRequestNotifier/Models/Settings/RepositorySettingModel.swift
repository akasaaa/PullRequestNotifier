//
//  RepositorySettingModel.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import Foundation

struct RepositorySettingModel: Codable {
    var createdAt = Date()
    var repository = ""
    var labelFilter = ""
    var showSelf = true
    var showApprove = true
    var accountSettingId = AccountSettingModel.ID()
}

extension RepositorySettingModel: Identifiable {
    var id: Date {
        createdAt
    }
}
