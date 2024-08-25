//
//  ViewModel.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI
import Combine

struct Repository {
    let user: String
    let repository: String
    let pullRequests: [PullRequest]
}
extension Repository: Identifiable {
    var id: String {
        return [user, repository].joined(separator: "/")
    }
}

class ViewModel: ObservableObject {

    @AppStorage("repositorySettingList") private var repositorySettingList = Data()
    @AppStorage("currentUserAccount") private var currentUserAccount = ""
    @AppStorage("showSelf") private var showSelf = true
    @AppStorage("showApprove") private var showApprove = true
    @AppStorage("startHour") private var startHour = 10
    @AppStorage("endHour") private var endHour = 19
    @AppStorage("fetchInterval") private var fetchInterval = 300

    private let notifier = Notifier()
    private let fetcher: FetcherProtocol
    private var timerCancelable: AnyCancellable?
    private var nextUpdateSecondsTimerCancelable: AnyCancellable?
    private var nextUpdateDate: Date?

    private let decoder = JSONDecoder()
    private var repositories: [RepositorySetting] {
        let decoded = try? decoder.decode([RepositorySetting].self, from: repositorySettingList)
        return (decoded ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    private(set) lazy var invalidParameterAlert = (title: "Set Github informations.",
                                                   message: Optional<String>.none,
                                                   buttons: [(title: "OK",
                                                              handler: { self.showPreferences() })])

    @Published var fetchedData = [Repository]()
    @Published var shouldShowAlert = false
    @Published var shouldShowPreferences = false
    @Published var untilNextUpdateText = ""

    init(fetcher: FetcherProtocol = Fetcher()) {
        self.fetcher = fetcher
        setup()
    }

    private func setup() {
        notifier.authorize()
        setupTimers()
    }

    private func setupTimers() {
        setupNextUpdateSecondsTimer()
        updateFetchTimer()
    }

    private func setupNextUpdateSecondsTimer() {
        nextUpdateSecondsTimerCancelable = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] current in
                guard let self, let nextUpdateDate else { return }
                let seconds = Int(nextUpdateDate.timeIntervalSince(current))
                self.untilNextUpdateText = seconds == 0 ? "updating..." : "next: \(seconds)s"
            }
    }

    private func updateFetchTimer() {
        nextUpdateDate = Date().addingTimeInterval(Double(fetchInterval))
        timerCancelable = Timer.publish(every: Double(fetchInterval), on: .main, in: .default)
            .autoconnect()
            .sink(receiveValue: { [weak self] hoge in
                guard let self else { return }
                nextUpdateDate = Date().addingTimeInterval(Double(fetchInterval))
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
            })
    }

    @MainActor
    func update(withNotify: Bool) async {
        updateFetchTimer()

        let results = await withTaskGroup(of: Repository?.self, returning: [Repository].self) { group in
            for repositorySetting in repositories {
                group.addTask {
                    await self.fetch(repositorySetting: repositorySetting, withNotify: withNotify)
                }
            }
            var results = [Repository]()
            for await repository in group {
                if let repository {
                    results.append(repository)
                }
            }
            return results
        }
        fetchedData = results
    }

    private func fetch(repositorySetting: RepositorySetting, withNotify: Bool) async -> Repository? {
        let token = repositorySetting.token
        let host = repositorySetting.host
        let user = repositorySetting.user
        let repository = repositorySetting.repository
        let labelFilter = repositorySetting.labelFilter
        do {
            let previous = fetchedData.first { $0.user == repositorySetting.user && $0.repository == repositorySetting.repository }
            let pullRequests = try await fetcher.getPullRequests(host: host, user: user, repository: repository, token: token)
                .filter { pull in
                    if showSelf {
                        return true
                    } else {
                        return pull.user?.login != currentUserAccount
                    }
                }
                .filter { pull in
                    if showApprove {
                        return true
                    } else {
                        return !pull.reviews.contains { $0.user?.login == currentUserAccount && $0.state == "APPROVED" }
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
            if withNotify {
                let newPullRequests = pullRequests.filter { pull in !(previous?.pullRequests ?? []).contains { $0.number == pull.number } }
                newPullRequests.forEach {
                    notifier.notify(pull: $0)
                }
            }

            return Repository(user: user, repository: repository, pullRequests: pullRequests)
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
            return nil
        }
    }

    func didTap(_ pullRequest: PullRequest) {
        guard let url = pullRequest.url else {
            return
        }
        let workspace = NSWorkspace.shared
        workspace.open(url)
    }

    private func showPreferences() {
        preferenceWindow.center()
        preferenceWindow.makeKeyAndOrderFront(nil)
        NSApp.windows.forEach { if ($0.canBecomeMain) {$0.orderFrontRegardless() } }
    }
}

