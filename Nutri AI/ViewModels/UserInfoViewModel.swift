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

    func loadUserInfo() -> UserInfoModel? {
        let descriptor = FetchDescriptor<UserInfoModel>()
        return try? modelContext.fetch(descriptor).first
    }
}
