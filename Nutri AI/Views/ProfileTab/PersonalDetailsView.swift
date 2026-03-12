//
//  PersonalDetailsView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 24/02/26.
//

import SwiftData
import SwiftUI

struct PersonalDetailsView: View {
    @Query private var users: [UserInfoModel]
    @State private var userInfoViewModel: UserInfoViewModel?
    @State private var desiredWeight: Double?
    @State private var currentWeight: Double?
    @Environment(\.modelContext) private var modelContext
    @Environment(FloatingButtonVisibility.self) private var floatingButtonVisibility

    private var viewModel: UserInfoViewModel {
        if let existing = userInfoViewModel {
            return existing
        }
        let vm = UserInfoViewModel(modelContext: modelContext)
        userInfoViewModel = vm
        return vm
    }

    private var currentUserInfo: UserInfoModel? {
        users.first ?? viewModel.loadUserInfo()
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Personal Details")
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
                .padding(.top, -230)

            goalWeightView

            personalInfoCardView
        }
        .onAppear {
            floatingButtonVisibility.isHidden = true
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private enum PersonalInfoRow: CaseIterable, Identifiable {
        case currentWeight
        case height
        case dateOfBirth
        case gender

        var id: String { title }

        var title: String {
            switch self {
            case .currentWeight: "Current weight"
            case .height: "Height"
            case .dateOfBirth: "Date of birth"
            case .gender: "Gender"
            }
        }

        func valueText(userInfo: UserInfoModel?) -> String {
            switch self {
            case .currentWeight:
                userInfo?.weightInKg.formattedWeight() ?? "Not set"
            case .height:
                userInfo?.heightInCm.formattedHeight() ?? "Not set"
            case .dateOfBirth:
                userInfo?.dob.map { Self.dateFormatter.string(from: $0) } ?? "Not set"
            case .gender:
                userInfo?.gender?.rawValue.capitalized ?? "Not set"
            }
        }

        @ViewBuilder
        func destination() -> some View {
            switch self {
            case .currentWeight:
                UpdateWeightView(mode: .currentWeight)
            case .height:
                UpdateHeightView()
            case .dateOfBirth:
                UpdateDateOfBirthView()
            case .gender:
                UpdateGenderView()
            }
        }

        private static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yyyy"
            return formatter
        }()
    }

    private var goalWeightView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Goal Weight")
                        .font(.system(size: 14, weight: .medium))

                    Text(goalWeightText)
                        .font(.system(size: 14, weight: .semibold))
                }
                Spacer()
                NavigationLink {
                    UpdateWeightView(mode: .goalWeight)
                } label: {
                    Text("Change Goal")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.black))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 84)
        .padding(.horizontal, 20)
    }

    private var personalInfoCardView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
            VStack(spacing: 0) {
                ForEach(PersonalInfoRow.allCases) { row in
                    personalInfoRowView(row)
                    if row != PersonalInfoRow.allCases.last {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .padding(.horizontal, 20)
    }

    private func personalInfoRowView(_ row: PersonalInfoRow) -> some View {
        NavigationLink {
            row.destination()
        } label: {
            personalInfoRowContent(row)
        }
        .buttonStyle(.plain)
    }

    private func personalInfoRowContent(_ row: PersonalInfoRow) -> some View {
        HStack(spacing: 12) {
            Text(row.title)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.85))
            Spacer()
            Text(row.valueText(userInfo: currentUserInfo))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.black)
            Image(systemName: "pencil")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var goalWeightText: String {
        currentUserInfo?.desiredWeightInKg.formattedWeight() ?? "Not set"
    }

    private func loadSavedData() {
        if let userInfo = viewModel.loadUserInfo() {
            if userInfo.desiredWeightInKg > 0 {
                desiredWeight = userInfo.desiredWeightInKg
            }
            if userInfo.weightInKg > 0 {
                currentWeight = userInfo.weightInKg
            }
        }
    }
}

#Preview {
    NavigationStack {
        PersonalDetailsView()
    }
}
