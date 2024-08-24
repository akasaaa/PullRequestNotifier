//
//  PullRow.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

protocol PullRowApplicable {
    var title: String { get }
    var number: Int { get }
    var owner: String { get }
    var approvedUser: [String] { get }
    var currentUser: String { get }
}

struct PullRow: View {

    let pull: PullRowApplicable

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                let text = Text("#" + pull.number.description)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(width: 50)
                if pull.owner == pull.currentUser {
                    text.foregroundStyle(Color(hex6: 0x56d364))
                } else {
                    text
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                let title = Text(pull.title)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                if pull.owner == pull.currentUser {
                    title.foregroundStyle(Color(hex6: 0x56d364))
                } else {
                    title
                }
                if !pull.approvedUser.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(pull.approvedUser, id: \.description) { approvedUser in
                            let user = Text(approvedUser)
                            if approvedUser == pull.currentUser {
                                user.foregroundStyle(Color(hex6: 0x56d364))
                            } else {
                                user
                            }
                        }
                        Text("Approved")
                    }
                }
            }
        }
    }
}

struct PullRow_Previews: PreviewProvider {

    struct Example: PullRowApplicable {
        let number: Int
        let title: String
        let approvedUser: [String]
        let currentUser: String
        let owner: String
    }

    static var previews: some View {
        PullRow(pull: Example(number: 100,
                              title: "PullRequest title",
                              approvedUser: ["AAAA", "BBBB"],
                              currentUser: "CCCC",
                              owner: "CCCC"))
        .frame(width: 400)
    }
}

extension Color {
    /// #RRGGBBの6桁の16進数からUIColorを作成する
    init(hex6: UInt32) {
        let divisor = CGFloat(255)
        let red = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green = CGFloat((hex6 & 0x00FF00) >> 8) / divisor
        let blue = CGFloat(hex6 & 0x0000FF) / divisor
        self.init(red: red, green: green, blue: blue)
    }
}
