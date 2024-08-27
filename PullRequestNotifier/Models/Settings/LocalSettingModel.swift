//
//  LocalSettingModel.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import Foundation

struct LocalSettingModel: Codable {
    var startHour = 10
    var endHour = 19
    var fetchInterval = 300
}
