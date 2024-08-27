//
//  PullList.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct PullList: View {

    @AppStorage(AppStorageKey.accountSettingListData) private var accountSettingListData = Data()
    @AppStorage(AppStorageKey.repositorySettingListData) private var repositorySettingListData = Data()
    @AppStorage(AppStorageKey.localSettingData) private var localSettingData = Data()
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    Task {
                        await viewModel.update(withNotify: true)
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                Text(viewModel.untilNextUpdateText)
                Spacer()
                Button(action: {
                    viewModel.showPreferences()
                }) {
                    Image(systemName: "gearshape")
                }
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 08))
            List {
                ForEach(viewModel.fetchedSections) { section in
                    Section(section.repositorySetting.repository) {
                        ForEach(section.pullRequests, id: \.number) { pullRequest in
                            PullRow(accountSetting: section.accountSetting,
                                    pullRequest: pullRequest)
                                .onTapGesture {
                                    viewModel.didTap(pullRequest)
                                }
                        }
                    }
                }
            }
            .task {
                await viewModel.update(withNotify: false)
            }
            .alert(viewModel.invalidParameterAlert.title, isPresented: $viewModel.shouldShowAlert) {
                ForEach(viewModel.invalidParameterAlert.buttons, id: \.title) { button in
                    Button(button.title, action: button.handler)
                }
            }
        }
        .onChange(of: [accountSettingListData, repositorySettingListData, localSettingData]) {
            Task {
                await viewModel.update(withNotify: true)
            }
        }
        .background {
            Color(NSColor.windowBackgroundColor)
        }
    }
}

struct PullList_Previews: PreviewProvider {

    static var previews: some View {
        PullList()
            .frame(width: 400.0, height: 600)
    }
}
