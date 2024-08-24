//
//  LocalSettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct LocalSettings: View {

    @AppStorage("showSelf") private var showSelf = true
    @AppStorage("showApprove") private var showApprove = true
    @AppStorage("startHour") private var startHour = 10
    @AppStorage("endHour") private var endHour = 19
    @AppStorage("fetchInterval") private var fetchInterval = 300

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("show self pull request: ")
                HStack {
                    Toggle(isOn: $showSelf) {}
                        .toggleStyle(.switch)
                        .labelsHidden()
                    Spacer()
                }
                .frame(width: 180)
            }
            HStack {
                Text("show already approved pull request: ")
                HStack {
                    Toggle(isOn: $showApprove) {}
                        .toggleStyle(.switch)
                        .labelsHidden()
                    Spacer()
                }
                .frame(width: 180)
            }
            HStack {
                Text("business hours: ")
                HStack {
                    Picker("", selection: $startHour) {
                        let data = (0..<endHour).map { $0 }
                        ForEach(data, id: \.hashValue) {
                            Text("\($0)").tag($0)
                        }
                    }.labelsHidden()
                    Text("時 〜 ")
                    Picker("", selection: $endHour) {
                        let data = ((startHour + 1)...24).map { $0 }
                        ForEach(data, id: \.hashValue) {
                            Text("\($0)").tag($0)
                        }
                    }.labelsHidden()
                    Text("時")
                    Spacer()
                }
                .frame(width: 180)
            }
            HStack {
                Text("fetch interval: ")
                HStack {
                    Picker("", selection: $fetchInterval) {
                        let data = stride(from: 30, to: 630, by: 30)
                        ForEach(Array(data), id: \.hashValue) {
                            Text("\($0)").tag($0)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 60)
                    Text("s")
                    Spacer()
                }
                .frame(width: 180)
            }
        }
        .frame(width: 500)
    }
}

struct LocalSettings_Previews: PreviewProvider {
    static var previews: some View {
        LocalSettings()
            .frame(width: 600, height: 400)
    }
}
