//
//  LoginView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import GoogleSignIn
import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.appTheme) private var theme

    private func signInWithGoogle() {
        Task {
            if await viewModel.signInWithGoogle() == true {
                dismiss()
            }
        }
    }

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center) {
                Button(action: signInWithGoogle) {
                    HStack(spacing: 12) {
                        Image("Google")
                            .frame(width: 26, height: 26)
                        Text("Sign in with Google")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(theme.primaryFill)
                    }
                    .frame(width: 255, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(theme.primaryFillContent)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(theme.primaryFill, lineWidth: 2)
                    }
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
