//
//  TextListEditView.swift
//  PullRequestNotifier
//
//  Created by 赤迫亮太 on 2024/08/31.
//

import SwiftUI

struct TextListEditView: View {
    @Binding var textList: [String]
    @State private var newText = ""

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .trailing) {
            List {
                ForEach(textList.indices, id: \.self) { index in
                    if !textList[index].isEmpty {
                        TextField("", text: $textList[index])
                            .labelsHidden()
                    }
                }
                TextField("input text", text: $newText, onEditingChanged: { isEditing in
                    guard !isEditing else {
                        return
                    }
                    if textList.allSatisfy({ $0 != newText }) {
                        textList.append(newText)
                    }
                })
                .labelsHidden()
            }
            Button("閉じる") {
                if !newText.isEmpty && textList.allSatisfy({ $0 != newText }) {
                    textList.append(newText)
                }
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 8))
        }
        .onChange(of: textList) { _, current in
            textList = current.filter { !$0.isEmpty }
            newText = ""
        }
    }
}

#Preview {
    @State var textList = [String]()
    return TextListEditView(textList: $textList)
}
