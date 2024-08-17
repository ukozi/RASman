//
//  AboutView.swift
//  RASman
//
//  Created by Lucas J. Chumley on 8/16/24.
//

import SwiftUI

struct CustomAboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("About This App")
                .font(.title)
                .padding(.top)

            Text("Made with ❤️ by Lucas in Tennessee.")
                .font(.body)
                .padding()

            Spacer()

            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .keyboardShortcut(.defaultAction)
            .padding()
        }
        .frame(width: 400, height: 200)
        .padding()
    }
}
