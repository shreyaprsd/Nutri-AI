//
//  NewUserOnboardingView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 13/01/26.
//

import SwiftUI

struct NewUserOnboardingView: View {
    @State private var presentLoginSheet = false
    @ObservedObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            Spacer()
            Text("""
            Calorie tracking 
            made easy 📝
            """)
            .font(.system(size: 32, weight: .semibold))

            Spacer()

            NavigationLink(destination: GenderView(authViewModel: authViewModel)) {
                PrimaryButton(title: "Get Started")
            }
            .padding()

            HStack {
                Text("Already have an account?")
                    .font(.system(size: 14, weight: .regular))
                Text("Sign in")
                    .font(.system(size: 14, weight: .semibold))
                    .onTapGesture {
                        presentLoginSheet = true
                    }
            }
        }
        .sheet(isPresented: $presentLoginSheet) {
            NavigationView {
                LoginView(viewModel: authViewModel)
                    .presentationDetents([.medium])
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                presentLoginSheet = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
        }
    }
}
