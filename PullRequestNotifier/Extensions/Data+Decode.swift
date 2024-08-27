//
//  Decodable+Decode.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/26.
//

import Foundation

let decoder = JSONDecoder()

extension Data {
    func decoded<T: Decodable>(_ type: T.Type) -> T? {
        do {
            return try decoder.decode(T.self, from: self)
        } catch {
            print("decode failed. error: \(error)")
            return nil
        }
    }
}
