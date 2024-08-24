//
//  ViewModel.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct RowData: PullRowApplicable {
    let number: Int
    let title: String
    let owner: String
    let approvedUser: [String]
    let currentUser: String

    init?(_ pullRequest: PullRequest, currentUser: String) {
        self.number = pullRequest.number
        self.title = pullRequest.title ?? "-"
        self.owner = pullRequest.user?.login ?? ""
        self.approvedUser = pullRequest.reviews.compactMap { review in
            guard review.state == "APPROVED" else {
                return nil
            }
            return review.user?.login
        }
        self.currentUser = currentUser
    }
}

class ViewModel: ObservableObject {

    @AppStorage("token") private var token = ""
    @AppStorage("host") private var host = ""
    @AppStorage("user") private var user = ""
    @AppStorage("repository") private var repository = ""
    @AppStorage("userName") private var userName = ""
    @AppStorage("labelFilter") private var labelFilter = ""
    @AppStorage("showSelf") private var showSelf = true
    @AppStorage("showApprove") private var showApprove = true
    @AppStorage("startHour") private var startHour = 10
    @AppStorage("endHour") private var endHour = 19
    @AppStorage("fetchInterval") private var fetchInterval = 300 {
        didSet {
            print("----fetchInterval didSet", fetchInterval)
        }
    }

    private let notifier = Notifier()
    private let fetcher: FetcherProtocol

    private var timer: Timer?

    private var pulls = [PullRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.rows = self.pulls.compactMap { RowData($0, currentUser: self.userName) }
            }
        }
    }
    private(set) lazy var invalidParameterAlert = (title: "Set Github informations.",
                                                   message: Optional<String>.none,
                                                   buttons: [(title: "OK",
                                                              handler: { self.showPreferences() })])

    @Published var rows = [PullRowApplicable]()
    @Published var shouldShowAlert = false
    @Published var shouldShowPreferences = false

    init(fetcher: FetcherProtocol = Fetcher()) {
        self.fetcher = fetcher
        setup()
    }

    private func setup() {
        notifier.authorize()
        setupTimer()
    }

    private func setupTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: Double(fetchInterval), repeats: true) { _ in
                Task {
                    let currentDate = Date()
                    var components = Calendar(identifier: .gregorian).dateComponents(in: .current, from: currentDate)
                    components.hour = self.startHour
                    components.minute = 0
                    let from = components.date ?? currentDate.addingTimeInterval(-1)
                    components.hour = self.endHour
                    let to = components.date ?? currentDate.addingTimeInterval(1)
                    guard from ... to ~= currentDate else {
                        return
                    }
                    await self.update(withNotify: true)
                }
            }
        }
    }

    func update(withNotify: Bool) async {
        if timer?.timeInterval != Double(fetchInterval) {
            setupTimer()
        }
        do {
            let previous = pulls
            pulls = try await fetcher.getPullRequests(host: host, user: user, repository: repository, token: token)
                .filter { pull in
                    if showSelf {
                        return true
                    } else {
                        return pull.user?.login != userName
                    }
                }
                .filter { pull in
                    if showApprove {
                        return true
                    } else {
                        return !pull.reviews.contains { $0.user?.login == userName && $0.state == "APPROVED" }
                    }
                }
                .filter { pull in
                    if labelFilter.isEmpty {
                        return true
                    } else {
                        return pull.labels?.contains { $0.name == labelFilter } ?? false
                    }
                }
            // TODO: showSelf切り替えとかを考慮したロジックにする
            guard withNotify else {
                return
            }
            let newPulls = pulls.filter { pull in !previous.contains { $0.number == pull.number } }
            newPulls.forEach {
                notifier.notify(pull: $0)
            }
        } catch {
            if let error = error as? PullRequestNotifier.Error {
                switch error {
                case .invalidParameters:
                    DispatchQueue.main.async { [weak self] in
                        self?.shouldShowAlert = true
                    }
                default:
                    break
                }
            }
            print("--- fetch failed. \(error)")
        }
    }

    func didTap(_ row: PullRowApplicable) {
        // イケてない
        guard let pullRequest = pulls.first(where: { $0.number == row.number }), let url = pullRequest.url else {
            return
        }
        let workspace = NSWorkspace.shared
        workspace.open(url)
    }

    private func showPreferences() {
        let window = NSWindow()
        window.styleMask.insert(.closable)
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: Preferences().frame(width: 600, height: 400))
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.windows.forEach { if ($0.canBecomeMain) {$0.orderFrontRegardless() } }
    }
}

