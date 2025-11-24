//
//  ProfileView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var auth: AuthViewModel
    var body: some View {
        Button("Logout") {
            auth.signOut()
        }
    }
}

#Preview {
    ProfileView(auth: AuthViewModel())
}
