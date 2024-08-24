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
            Button(action: {
                Task {
                    await viewModel.update(withNotify: true)
                }
            }) {
                Image(systemName: "arrow.clockwise")
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0))
            List {
                ForEach(viewModel.rows, id: \.number) { row in
                    PullRow(pull: row)
                        .onTapGesture {
                            viewModel.didTap(row)
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
