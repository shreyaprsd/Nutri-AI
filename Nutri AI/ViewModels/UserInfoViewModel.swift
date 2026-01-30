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

    private func syncToFirestore(_ userInfo: UserInfoModel) {
        Task {
            do {
                try await repository.saveUserInfoToFirestore(userInfo)
            } catch {
                logger.error("Firestore sync failed: \(error.localizedDescription)")
            }
        }
    }
    
    func saveGender(_ gender: Gender) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.gender = gender
        } else {
            let newUserInfo = UserInfoModel(gender: gender)
            modelContext.insert(newUserInfo)
        }
        do {
            try modelContext.save()
            logger.info("Saved gender sucessfully")
            if let userInfo = loadUserInfo() {
                syncToFirestore(userInfo)
            }
        } catch {
            logger.error(" Saving gender failed:\(error.localizedDescription)")
        }
    }

    func saveWorkoutFrequency(_ workoutFrequency: WorkoutFrequency) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.workoutFrequency = workoutFrequency
            do {
                try modelContext.save()
                logger.info("Saved workoutFrequency sucessfully")
                syncToFirestore(userInfo)
            } catch {
                logger.error(" Saving workout frequency  failed:\(error.localizedDescription)")
            }
        }
    }

    func saveHeightAndWeight(height: Double, weight: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.heightInCm = height
            userInfo.weightInKg = weight
            do {
                try modelContext.save()
                logger.info("Saved height and weight sucessfully")
                syncToFirestore(userInfo)
            } catch {
                logger.error(" Saving height and weight failed:\(error.localizedDescription)")
            }
        }
    }

    func saveDateOfBirth(_ dateOfBirth: Date) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.dob = dateOfBirth
            do {
                try modelContext.save()
                logger.info("Saved date of birth sucessfully")
                syncToFirestore(userInfo)
            } catch {
                logger.error("Saving date of birth failed:\(error.localizedDescription)")
            }
        }
    }

    func saveDesiredGoal(_ desiredGoal: Goal) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.desiredGoal = desiredGoal
            do {
                try modelContext.save()
                logger.info("Saved desired goal sucessfully")
                syncToFirestore(userInfo)
            } catch {
                logger.error("Saving desired goal failed:\(error.localizedDescription)")
            }
        }
    }

    func saveDesiredWeight(_ desiredWeight: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.desiredWeightInKg = desiredWeight
            do {
                try modelContext.save()
                logger.info("Saved desired weight sucessfully")
                syncToFirestore(userInfo)
            } catch {
                logger.error("Saving desired weight failed:\(error.localizedDescription)")
            }
        }
    }

    func saveAge(_ age: Int) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.age = age
            do {
                try modelContext.save()
                logger.info("Saved age sucessfully")
                syncToFirestore(userInfo)
            } catch {
                logger.error("Failed to save the user's age \(error.localizedDescription)")
            }
        }
    }

    func calculateAndSaveNutrition() {
        let descriptor = FetchDescriptor<UserInfoModel>()
        guard let userInfo = try? modelContext.fetch(descriptor).first else {
            logger.error("No user info found to calculate nutrition")
            return
        }

        if let calculations = NutritionCalculation.calculateAll(userInfo: userInfo) {
            userInfo.calculations = calculations
            do {
                try modelContext.save()
                logger.info("Saved nutrition calculations successfully")
                logger.info("BMR: \(calculations.bmr), TDEE: \(calculations.tdee), Target Calories: \(calculations.targetDailyCalories)")
                logger.info("Macros - Protein: \(calculations.macros.protein)g, Carbs: \(calculations.macros.carbs)g, Fats: \(calculations.macros.fats)g")
                syncToFirestore(userInfo)
            } catch {
                logger.error("Failed to save nutrition calculations: \(error.localizedDescription)")
            }
        } else {
            logger.error("Failed to calculate nutrition - missing required user data")
        }
    }

    func updateCalories(_ calories: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            if userInfo.calculations == nil {
                userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: calories,
                                                     macros: Macros(protein: 0, carbs: 0, fats: 0))
            } else {
                userInfo.calculations?.targetDailyCalories = calories
            }
            saveAndSync(userInfo)
        }
    }

    func updateCarbs(_ carbs: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            if userInfo.calculations == nil {
                userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: 0,
                                                     macros: Macros(protein: 0, carbs: carbs, fats: 0))
            } else {
                userInfo.calculations?.macros.carbs = carbs
            }
            saveAndSync(userInfo)
        }
    }

    func updateProtein(_ protein: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            if userInfo.calculations == nil {
                userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: 0,
                                                     macros: Macros(protein: protein, carbs: 0, fats: 0))
            } else {
                userInfo.calculations?.macros.protein = protein
            }
            saveAndSync(userInfo)
        }
    }

    func updateFats(_ fats: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            if userInfo.calculations == nil {
                userInfo.calculations = Calculations(bmr: 0, tdee: 0, targetDailyCalories: 0,
                                                     macros: Macros(protein: 0, carbs: 0, fats: fats))
            } else {
                userInfo.calculations?.macros.fats = fats
            }
            saveAndSync(userInfo)
        }
    }

    private func saveAndSync(_ userInfo: UserInfoModel) {
        do {
            try modelContext.save()
            logger.info("Local SwiftData update successful")
            if Auth.auth().currentUser != nil {
                syncToFirestore(userInfo)
            } else {
                logger.info("Skipping Firestore sync: User not authenticated")
            }
        } catch {
            logger.error("Failed to save nutrient update: \(error.localizedDescription)")
        }
    }

    func updateNutrient(nutrientType: NutrientType, value: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        guard let userInfo = try? modelContext.fetch(descriptor).first else {
            logger.error("No user info found")
            return
        }

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
