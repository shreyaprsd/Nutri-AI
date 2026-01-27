//
//  UserInfoViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/01/26.
//

import Foundation
import OSLog
import SwiftData
import UIKit

@Observable
class UserInfoViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    let logger = Logger(subsystem: "com.shreyaprasad.NutriAI", category: "UserInfoViewModel")

    // saves Gender selection
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
        } catch {
            logger.error(" Saving gender failed:\(error.localizedDescription)")
        }
    }

    // saves WorkoutFrequency selection
    func saveWorkoutFrequency(_ workoutFrequency: WorkoutFrequency) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.workoutFrequency = workoutFrequency
            do {
                try modelContext.save()
                logger.info("Saved workoutFrequency sucessfully")
            } catch {
                logger.error(" Saving workout frequency  failed:\(error.localizedDescription)")
            }
        }
    }

    // saves height and weight selection
    func saveHeightAndWeight(height: Double, weight: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.heightInCm = height
            userInfo.weightInKg = weight
            do {
                try modelContext.save()
                logger.info("Saved height and weight sucessfully")
            } catch {
                logger.error(" Saving height and weight failed:\(error.localizedDescription)")
            }
        }
    }

    // saves date of birth
    func saveDateOfBirth(_ dateOfBirth: Date) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.dob = dateOfBirth
            do {
                try modelContext.save()
                logger.info("Saved date of birth sucessfully")
            } catch {
                logger.error("Saving date of birth failed:\(error.localizedDescription)")
            }
        }
    }

    // saves desiredGoal selection
    func saveDesiredGoal(_ desiredGoal: Goal) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.desiredGoal = desiredGoal
            do {
                try modelContext.save()
                logger.info("Saved desired goal sucessfully")
            } catch {
                logger.error("Saving desired goal failed:\(error.localizedDescription)")
            }
        }
    }

    // saves desiredWeight
    func saveDesiredWeight(_ desiredWeight: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.desiredWeightInKg = desiredWeight
            do {
                try modelContext.save()
                logger.info("Saved desired weight sucessfully")
            } catch {
                logger.error("Saving desired weight failed:\(error.localizedDescription)")
            }
        }
    }

    // saves age
    func saveAge(_ age: Int) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.age = age
            do {
                try modelContext.save()
                logger.info("Saved age sucessfully")
            } catch {
                logger.error("Failed to save the user's age \(error.localizedDescription)")
            }
        }
    }

    // saves all calucation
    // calculates and saves nutrition data (BMR, TDEE, calories, macros)
    func calculateAndSaveNutrition() {
        let descriptor = FetchDescriptor<UserInfoModel>()
        guard let userInfo = try? modelContext.fetch(descriptor).first else {
            logger.error("No user info found to calculate nutrition")
            return
        }

        // Calculate all nutrition data
        if let calculations = NutritionCalculation.calculateAll(userInfo: userInfo) {
            userInfo.calculations = calculations
            do {
                try modelContext.save()
                logger.info("Saved nutrition calculations successfully")
                logger.info("BMR: \(calculations.bmr), TDEE: \(calculations.tdee), Target Calories: \(calculations.targetDailyCalories)")
                logger.info("Macros - Protein: \(calculations.macros.protein)g, Carbs: \(calculations.macros.carbs)g, Fats: \(calculations.macros.fats)g")
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
            userInfo.calculations?.targetDailyCalories = calories
            do {
                try modelContext.save()
                logger.info("Updated calories to \(calories) successfully")
            } catch {
                logger.error("Failed to update calories: \(error.localizedDescription)")
            }
        }
    }

    func updateCarbs(_ carbs: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.calculations?.macros.carbs = carbs
            do {
                try modelContext.save()
                logger.info("Updated carbs to \(carbs)g successfully")
            } catch {
                logger.error("Failed to update carbs: \(error.localizedDescription)")
            }
        }
    }

    func updateProtein(_ protein: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.calculations?.macros.protein = protein
            do {
                try modelContext.save()
                logger.info("Updated protein to \(protein)g successfully")
            } catch {
                logger.error("Failed to update protein: \(error.localizedDescription)")
            }
        }
    }

    func updateFats(_ fats: Double) {
        let descriptor = FetchDescriptor<UserInfoModel>()
        if let userInfo = try? modelContext.fetch(descriptor).first {
            userInfo.calculations?.macros.fats = fats
            do {
                try modelContext.save()
                logger.info("Updated fats to \(fats)g successfully")
            } catch {
                logger.error("Failed to update fats: \(error.localizedDescription)")
            }
        }
    }

    func updateNutrient(nutrientType: NutrientType, value: Double) {
        switch nutrientType {
        case .calories:
            updateCalories(value)
        case .carbs:
            updateCarbs(value)
        case .protein:
            updateProtein(value)
        case .fats:
            updateFats(value)
        }
    }

    func loadUserInfo() -> UserInfoModel? {
        let descriptor = FetchDescriptor<UserInfoModel>()
        return try? modelContext.fetch(descriptor).first
    }
}
