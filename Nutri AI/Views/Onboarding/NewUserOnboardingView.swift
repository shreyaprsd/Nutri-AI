//
//  NewUserOnboardingView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 13/01/26.
//

import SwiftUI

struct NewUserOnboardingView: View {
    @State private var presentLoginSheet = false
    var body: some View {
        VStack {
            Spacer()
            Text("""
            Calorie tracking 
            made easy 📝
            """)
            .font(.system(size: 32, weight: .semibold))
            
            Spacer()
            
            NavigationLink(destination: GenderView()) {
                Text("Get Started")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 310, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black)
                    )
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
                LoginView(viewModel: AuthViewModel())
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

#Preview {
    NewUserOnboardingView()
}
