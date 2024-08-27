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
    // TODO: onChange以外の方法で音をならすようにし、notificationSoundの初期値はnilにする
    @State private var notificationSound: SoundEffect? = .init(id: 0, name: "initial")

    private var isAppeared = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            HStack {
                Text("Business Hours: ")
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
                Text("Fetch Interval: ")
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
            HStack {
                Text("Notification Sound: ")
                HStack {
                    Picker("", selection: $notificationSound) {
                        Text("None").tag(nil as SoundEffect?)
                        ForEach(SoundEffect.systemSoundEffects, id: \.self) { sound in
                            Text(sound.name).tag(sound as SoundEffect?)
                        }
                    }
                    .labelsHidden()
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
                self.notificationSound = SoundEffect.systemSoundEffects.first { $0.name == decoded.notificationSoundName }
            }
        }
        .onChange(of: notificationSound, initial: true) { prev, sound in
            guard prev?.name != "initial" else {
                return
            }
            sound?.play()
            localSettingData = LocalSettingModel(startHour: startHour, endHour: endHour, fetchInterval: fetchInterval, notificationSoundName: notificationSound?.name).encoded
        }
        .onChange(of: [startHour, endHour, fetchInterval]) {
            localSettingData = LocalSettingModel(startHour: startHour, endHour: endHour, fetchInterval: fetchInterval, notificationSoundName: notificationSound?.name).encoded
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
