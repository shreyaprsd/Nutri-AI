//
//  AuthViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

internal import Combine
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import SwiftData
import SwiftUI

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

enum AuthenticationFlow {
    case login
    case signUp
}

enum AuthenticationError: Error {
    case tokenError(message: String)
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var flow: AuthenticationFlow = .login
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var displayName: String = ""
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener {
                _,
                    user in
                self.user = user
                self.authenticationState =
                    user == nil ? .unauthenticated : .authenticated
                self.displayName = user?.displayName ?? ""
                if let user {
                    Task {
                        await UserManager.shared.createUserDocument(for: user)
                    }
                }
            }
        }
    }

    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }

    func reset() {
        flow = .login
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }

    func deleteAccount(foodViewModel: FoodEntryViewModel) async {
        guard let user else {
            return
        }
        do {
            // delete the firebase document
            await UserManager.shared.deleteUserDocument(for: user)
            // delete the local data
            try await foodViewModel.deleteAllLocalFoodEntries()
            // delete the auth account
            try await user.delete()

        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
}

extension AuthViewModel {
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client id found in firebase configuration")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard
            let windowScene = UIApplication.shared.connectedScenes.first
            as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController
        else {
            print("There is no root view controller")
            return false
        }

        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                throw AuthenticationError.tokenError(
                    message: "ID Token Missing"
                )
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString
            )
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print(
                "User \(firebaseUser.uid) signed-in with email \(firebaseUser.email ?? "unknown")"
            )
            return true

        } catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
            return false
        }
    }
}
