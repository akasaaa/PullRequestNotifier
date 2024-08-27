//
//  Notifier.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import UserNotifications
import AppKit

struct Notifier {

    private let notificationCenter: UNUserNotificationCenter
    private let delegate = NotifierDelegate()

    init() {
        self.notificationCenter = UNUserNotificationCenter.current()
        self.notificationCenter.delegate = delegate
    }

    func authorize() {
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { authorized, error in
            error.map { print("error: \($0)") }
        }
    }

    func notify(pull: PullRequest, soundName: String?) {
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = "#" + pull.number.description
            content.subtitle = pull.title ?? ""
            content.interruptionLevel = .active
            if let soundName {
                content.sound = UNNotificationSound(named: .init(soundName))
            }
            // TODO: Identifier以外で渡す方法があればそちらを利用したい。userInfoに設定すると通知が出なくなる。
            let urlString = pull.url?.absoluteString ?? ""
            let request = UNNotificationRequest(identifier: urlString, content: content, trigger: nil)
            notificationCenter.add(request)
        }
    }
}

class NotifierDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let workspace = NSWorkspace.shared
        guard let url = URL(string: response.notification.request.identifier) else {
            return
        }
        workspace.open(url)
    }
}
