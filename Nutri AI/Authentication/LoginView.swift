//
//  LoginView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import GoogleSignIn
import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    private func signInWithGoogle() {
        Task {
            if await viewModel.signInWithGoogle() == true {
                dismiss()
            }
        }
    }

    var body: some View {
        VStack {
            Text("Login Page")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 10)

            Spacer()

            VStack(alignment: .center) {
                Button(action: signInWithGoogle) {
                    HStack(spacing: 12) {
                        Image("Google")
                            .frame(width: 25, height: 25)
                        Text("Sign in with Google")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .frame(width: 225, height: 50)
                }
                .buttonStyle(.bordered)
            }
            Spacer()
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
