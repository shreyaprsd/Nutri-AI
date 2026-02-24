//
//  ProfileView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import FirebaseAuth
import SwiftData
import SwiftUI

struct ProfileView: View {
    @ObservedObject var auth: AuthViewModel
    @State var foodViewModel: FoodEntryViewModel
    @Binding var hideFloatingButton: Bool
    @State private var showLogoutAlert: Bool = false
    @State private var showDeleteAlert: Bool = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            Section("Account") {
                NavigationLink {
                    PersonalDetailsView(hideFloatingButton: $hideFloatingButton)
                } label: {
                    HStack {
                        Image(systemName: "person.text.rectangle")
                        Text("Personal Details")
                    }
                }
            }

            Section("Account Actions") {
                Button {
                    showLogoutAlert = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Logout")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.gray)
                    }
                    .foregroundStyle(Color.black)
                }

                Button {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Account")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.gray)
                    }
                    .foregroundStyle(Color.black)
                }
            }
        }
        .listStyle(.insetGrouped)
        .alert("Log Out?", isPresented: $showLogoutAlert) {
            Button("Log Out", role: .destructive) {
                auth.signOut()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    try await auth.deleteAccount(foodViewModel: foodViewModel, modelContext: modelContext)
                }
            }
        } message: {
            Text("Are you sure you want to permanently delete your account? This action cannot be undone.")
        }
    }
}
