//
//  LocalSettings.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct LocalSettings: View {

    @AppStorage(AppStorageKey.localSettingData) private var localSettingData = Data()

    @State private var startHour = 10
    @State private var endHour = 19
    @State private var fetchInterval = 300

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("business hours: ")
                HStack {
                    Picker("", selection: $startHour) {
                        let data = (0..<endHour).map { $0 }
                        ForEach(data, id: \.hashValue) {
                            Text("\($0)").tag($0)
                        }
                    }
                    .labelsHidden()
                    Text("時 〜 ")
                    Picker("", selection: $endHour) {
                        let data = ((startHour + 1)...24).map { $0 }
                        ForEach(data, id: \.hashValue) {
                            Text("\($0)").tag($0)
                        }
                    }
                    .labelsHidden()
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
        .onAppear {
            if let decoded = localSettingData.decoded(LocalSettingModel.self) {
                self.startHour = decoded.startHour
                self.endHour = decoded.endHour
                self.fetchInterval = decoded.fetchInterval
            }
        }
        .onChange(of: [startHour, endHour, fetchInterval]) {
            localSettingData = LocalSettingModel(startHour: startHour, endHour: endHour, fetchInterval: fetchInterval).encoded
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
