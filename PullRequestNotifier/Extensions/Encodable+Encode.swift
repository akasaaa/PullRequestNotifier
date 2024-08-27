//
//  Encodable+encoded.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import Foundation

let encoder = JSONEncoder()

extension Encodable {
    var encoded: Data {
        do {
            return try encoder.encode(self)
        } catch {
            print("encode failed. error: \(error)")
            return Data()
        }
    }
}
