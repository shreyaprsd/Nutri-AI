//
//  UserInfoViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/01/26.
//

import FirebaseAuth
import Foundation
import OSLog
import SwiftData
import UIKit

@Observable
class UserInfoViewModel {
    private var modelContext: ModelContext
    private var repository: UserInfoRepository

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        repository = UserInfoRepository(modelContext: modelContext)
    }

    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "UserInfoViewModel")

    private func fetchOrCreateUserInfo() -> UserInfoModel {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }
        let newUserInfo = UserInfoModel()
        modelContext.insert(newUserInfo)
        return newUserInfo
    }

    private func syncToFirestore(_ userInfo: UserInfoModel) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await repository.saveUserInfoToFirestore(userInfo)
            } catch {
                logger.error("Firestore sync failed: \(error.localizedDescription)")
            }
        }
    }

    func saveGender(_ gender: Gender) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.gender = gender
        saveAndSync(userInfo, context: "Gender")
    }

    func saveWorkoutFrequency(_ workoutFrequency: WorkoutFrequency) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.workoutFrequency = workoutFrequency
        saveAndSync(userInfo, context: "Workout Frequency")
    }

    func saveHeightAndWeight(height: Double, weight: Double) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.heightInCm = height
        userInfo.weightInKg = weight
        saveAndSync(userInfo, context: "Height and Weight")
    }

    func saveDateOfBirth(_ dateOfBirth: Date) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.dob = dateOfBirth
        saveAndSync(userInfo, context: "Date of Birth")
    }

    func saveDesiredGoal(_ desiredGoal: Goal) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.desiredGoal = desiredGoal
        saveAndSync(userInfo, context: "Desired Goal")
    }

    func saveDesiredWeight(_ desiredWeight: Double) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.desiredWeightInKg = desiredWeight
        saveAndSync(userInfo, context: "Desired Weight")
    }

    func saveAge(_ age: Int) {
        let userInfo = fetchOrCreateUserInfo()
        userInfo.age = age
        saveAndSync(userInfo, context: "Age")
    }

    func calculateAndSaveNutrition() {
        let userInfo = fetchOrCreateUserInfo()
        let calculations = NutritionCalculation.calculateAll(userInfo: userInfo)
        userInfo.calculations = calculations
        saveAndSync(userInfo, context: "Nutrition Calculations")
    }

    func updateCalories(_ calories: Double) {
        let userInfo = fetchOrCreateUserInfo()
        if userInfo.calculations == nil {
            userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: calories,
                                                 macros: Macros(protein: 0, carbs: 0, fats: 0))
        } else {
            userInfo.calculations?.targetDailyCalories = calories
        }
        saveAndSync(userInfo, context: "Target Daily Calories")
    }

    func updateCarbs(_ carbs: Double) {
        let userInfo = fetchOrCreateUserInfo()
        if userInfo.calculations == nil {
            userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: 0,
                                                 macros: Macros(protein: 0, carbs: carbs, fats: 0))
        } else {
            userInfo.calculations?.macros.carbs = carbs
        }
        saveAndSync(userInfo, context: "Carbs")
    }

    func updateProtein(_ protein: Double) {
        let userInfo = fetchOrCreateUserInfo()
        if userInfo.calculations == nil {
            userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: 0,
                                                 macros: Macros(protein: protein, carbs: 0, fats: 0))
        } else {
            userInfo.calculations?.macros.protein = protein
        }
        saveAndSync(userInfo, context: "Protein")
    }

    func updateFats(_ fats: Double) {
        let userInfo = fetchOrCreateUserInfo()
        if userInfo.calculations == nil {
            userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: 0,
                                                 macros: Macros(protein: 0, carbs: 0, fats: fats))
        } else {
            userInfo.calculations?.macros.fats = fats
        }
        saveAndSync(userInfo, context: "Fats")
    }

    private func saveAndSync(_ userInfo: UserInfoModel, context: String) {
        do {
            try modelContext.save()
            logger.info("\(context) SwiftData update successful")
            if Auth.auth().currentUser != nil {
                syncToFirestore(userInfo)
            } else {
                logger.info("Skipping Firestore sync: User not authenticated")
            }
        } catch {
            logger.error("\(context) save failed \(error.localizedDescription)")
        }
    }

    func updateNutrient(nutrientType: NutrientType, value: Double) {
        let userInfo = fetchOrCreateUserInfo()

        guard let currentCalc = userInfo.calculations else {
            logger.error("No calculations found - initializing with new value")

            let newMacros = Macros(
                protein: nutrientType == .protein ? value : 0,
                carbs: nutrientType == .carbs ? value : 0,
                fats: nutrientType == .fats ? value : 0
            )
            userInfo.calculations = Calculations(
                bmr: 0,
                tdee: 0,
                targetDailyCalories: nutrientType == .calories ? value : 0,
                macros: newMacros
            )
            saveAndSyncHelper(userInfo)
            return
        }

        switch nutrientType {
        case .calories:
            userInfo.calculations = Calculations(
                bmr: currentCalc.bmr,
                tdee: currentCalc.tdee,
                targetDailyCalories: value,
                macros: currentCalc.macros
            )
        case .carbs:
            userInfo.calculations = Calculations(
                bmr: currentCalc.bmr,
                tdee: currentCalc.tdee,
                targetDailyCalories: currentCalc.targetDailyCalories,
                macros: Macros(
                    protein: currentCalc.macros.protein,
                    carbs: value,
                    fats: currentCalc.macros.fats
                )
            )
        case .protein:
            userInfo.calculations = Calculations(
                bmr: currentCalc.bmr,
                tdee: currentCalc.tdee,
                targetDailyCalories: currentCalc.targetDailyCalories,
                macros: Macros(
                    protein: value,
                    carbs: currentCalc.macros.carbs,
                    fats: currentCalc.macros.fats
                )
            )
        case .fats:
            userInfo.calculations = Calculations(
                bmr: currentCalc.bmr,
                tdee: currentCalc.tdee,
                targetDailyCalories: currentCalc.targetDailyCalories,
                macros: Macros(
                    protein: currentCalc.macros.protein,
                    carbs: currentCalc.macros.carbs,
                    fats: value
                )
            )
        }

        saveAndSyncHelper(userInfo)
    }

    private func saveAndSyncHelper(_ userInfo: UserInfoModel) {
        do {
            try modelContext.save()
            logger.info("Local SwiftData update successful")

            modelContext.processPendingChanges()

            if Auth.auth().currentUser != nil {
                Task(priority: .background) {
                    do {
                        try await repository.saveUserInfoToFirestore(userInfo)
                        logger.info("Synced to Firestore")
                    } catch {
                        logger.error("Firestore sync failed: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            logger.error("Failed to save: \(error.localizedDescription)")
        }
    }

    func deleteUserInfo() async throws {
        let descriptor = FetchDescriptor<UserInfoModel>()
        guard let userInfo = try modelContext.fetch(descriptor).first else {
            logger.info("No local user info to delete")
            return
        }

        try await repository.deleteUserInfoFromBothDB(userInfo)
        logger.info("Successfully deleted UserInfo from both local and Firestore")
    }

    func loadUserInfo() -> UserInfoModel? {
        let descriptor = FetchDescriptor<UserInfoModel>()
        return try? modelContext.fetch(descriptor).first
    }

    func uploadLocalData() async {
        guard let userInfo = loadUserInfo() else {
            logger.error("No local data found to upload")
            return
        }

        do {
            try await repository.saveUserInfoToFirestore(userInfo)
            logger.info("Onboarding data successfully synced to Firestore")
        } catch {
            logger.error("Final upload failed: \(error.localizedDescription)")
        }
    }
}
