//
//  PullList.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/24.
//

import SwiftUI

struct PullList: View {

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
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
            List {
                ForEach(viewModel.pullRequests, id: \.number) { pullRequest in
                    PullRow(pullRequest: pullRequest)
                        .onTapGesture {
                            viewModel.didTap(pullRequest)
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
        }.background {
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
