//
//  PullRow.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct PullRow: View {

    let pullRequest: PullRequest

    @AppStorage("currentUserAccount") private var currentUserAccount = ""

    var body: some View {
        HStack(alignment: .top) {
            VStack {
                let text = Text("#" + pullRequest.number.description)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .frame(width: 50)
                if pullRequest.user?.login == currentUserAccount {
                    text.foregroundStyle(Color(hex6: 0x56d364))
                } else {
                    text
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                let title = Text(pullRequest.title ?? "-")
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                if pullRequest.user?.login == currentUserAccount {
                    title.foregroundStyle(Color(hex6: 0x56d364))
                } else {
                    title
                }
                let approved = pullRequest.reviews.filter { $0.state == "APPROVED" }
                if !approved.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(approved, id: \.user?.login) { review in
                            let user = Text(review.user?.login ?? "unknown user")
                            if review.user?.login == currentUserAccount {
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

extension Review: Identifiable {}

// TODO: 書く
//struct PullRow_Previews: PreviewProvider {
//
//    static var previews: some View {
//        PullRow(pull: Example(number: 100,
//                              title: "PullRequest title",
//                              approvedUser: ["AAAA", "BBBB"],
//                              currentUser: "CCCC",
//                              owner: "CCCC"))
//        .frame(width: 400)
//    }
//}

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
