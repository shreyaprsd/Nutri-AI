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
                    }
                    .frame(width: 255, height: 50)
                }
                .foregroundStyle(Color.black)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.black, lineWidth: 2)
                )
            }
            Spacer()
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
