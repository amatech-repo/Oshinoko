//
//  ChatTab.swift
//  Oshinoko
//
//  Created by 櫻井絵理香 on 2024/11/20.
//

import SwiftUI

struct ChatTab: View {
    @ObservedObject var viewModel: ChatViewModel
    let currentUserID: String
    let currentUserName: String
    let currentUserIcon: String?

    var body: some View {
        ChatView(viewModel: viewModel, currentUserID: currentUserID, currentUserName: currentUserName, currentUserIcon: currentUserIcon)
    }
}
