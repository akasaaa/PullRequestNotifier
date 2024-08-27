//
//  ViewModel.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI
import Combine

struct FetchedSection {
    let repositorySetting: RepositorySettingModel
    let accountSetting: AccountSettingModel
    let pullRequests: [PullRequest]
}

extension FetchedSection: Identifiable {
    var id: RepositorySettingModel.ID {
        repositorySetting.id
    }
}

class ViewModel: ObservableObject {

    @AppStorage(AppStorageKey.accountSettingListData) private var accountSettingListData = Data()
    @AppStorage(AppStorageKey.repositorySettingListData) private var repositorySettingListData = Data()
    @AppStorage(AppStorageKey.localSettingData) private var localSettingData = Data()

    private let notifier = Notifier()
    private let fetcher: FetcherProtocol
    private var timerCancelable: AnyCancellable?
    private var nextUpdateSecondsTimerCancelable: AnyCancellable?
    private var nextUpdateDate: Date?

    private var accountSettingList: [AccountSettingModel] {
        return accountSettingListData.decoded([AccountSettingModel].self) ?? []
    }
    private var repositorySettingList: [RepositorySettingModel] {
        return repositorySettingListData.decoded([RepositorySettingModel].self)?
            .sorted { $0.createdAt < $1.createdAt }
            ?? []
    }
    private var localSetting: LocalSettingModel {
        return localSettingData.decoded(LocalSettingModel.self) ?? .init()
    }

    private(set) lazy var invalidParameterAlert = (title: "Set Github informations.",
                                                   message: Optional<String>.none,
                                                   buttons: [(title: "OK",
                                                              handler: { self.showPreferences() })])

    @Published var fetchedSections = [FetchedSection]()
    @Published var shouldShowAlert = false
    @Published var shouldShowPreferences = false
    @Published var untilNextUpdateText = ""

    init(fetcher: FetcherProtocol = Fetcher()) {
        self.fetcher = fetcher
        setup()
//        $repositorySettingListData
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
        let fetchInterval = Double(localSetting.fetchInterval)
        nextUpdateDate = Date().addingTimeInterval(fetchInterval)
        timerCancelable = Timer.publish(every: fetchInterval, on: .main, in: .default)
            .autoconnect()
            .sink(receiveValue: { [weak self] current in
                guard let self else { return }
                nextUpdateDate = current.addingTimeInterval(fetchInterval)
                Task {
                    let currentDate = Date()
                    var components = Calendar(identifier: .gregorian).dateComponents(in: .current, from: currentDate)
                    components.hour = self.localSetting.startHour
                    components.minute = 0
                    let from = components.date ?? currentDate.addingTimeInterval(-1)
                    components.hour = self.localSetting.endHour
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

        let results = await withTaskGroup(of: FetchedSection?.self, returning: [FetchedSection].self) { group in
            for repositorySetting in repositorySettingList {
                group.addTask {
                    await self.fetch(repositorySetting: repositorySetting, withNotify: withNotify)
                }
            }
            var results = [FetchedSection]()
            for await repository in group {
                if let repository {
                    results.append(repository)
                }
            }
            return results
        }
        fetchedSections = results
    }

    private func fetch(repositorySetting: RepositorySettingModel, withNotify: Bool) async -> FetchedSection? {
        guard let accountSetting = accountSettingList.first(where: { $0.id == repositorySetting.accountSettingId }) else {
            return nil
        }
        let token = accountSetting.token
        let host = accountSetting.host
        let repository = repositorySetting.repository
        let labelFilter = repositorySetting.labelFilter
        do {
            let previous = fetchedSections.first { $0.repositorySetting.id == repositorySetting.id }
            let pullRequests = try await fetcher.getPullRequests(host: host, repository: repository, token: token)
                .filter { pull in
                    if repositorySetting.showSelf {
                        return true
                    } else {
                        return pull.user?.login != accountSetting.userName
                    }
                }
                .filter { pull in
                    if repositorySetting.showApprove {
                        return true
                    } else {
                        return !pull.reviews.contains { $0.user?.login == accountSetting.userName && $0.state == "APPROVED" }
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

            return FetchedSection(repositorySetting: repositorySetting, accountSetting: accountSetting, pullRequests: pullRequests)
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

    func showPreferences() {
        preferenceWindow.center()
        preferenceWindow.makeKeyAndOrderFront(nil)
        NSApp.windows.forEach { if ($0.canBecomeMain) {$0.orderFrontRegardless() } }
    }
}

