//
//  NutritionModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 19/11/25.
//

import Foundation
import SwiftData
import UIKit

@Model
final class NutritionModel {
    @Attribute(.unique) var id = UUID()
    var createdAt: Date
    @Attribute(.externalStorage) var imageData: Data?
    var foodName: String
    var calories: String
    var servingSize: String
    var foodDescription: String

    var carbs: StoredNutrient
    var protein: StoredNutrient
    var fats: StoredNutrient
    var saturatedFats: StoredNutrient
    var polysaturatedFats: StoredNutrient
    var cholesterol: StoredNutrient
    var sodium: StoredNutrient
    var potassium: StoredNutrient
    var vitaminA: StoredNutrient
    var vitaminC: StoredNutrient
    var iron: StoredNutrient
    var calcium: StoredNutrient
    var fiber: StoredNutrient
    var sugar: StoredNutrient

    init(createdAt: Date, imageData: Data?, response: NutritionResponse) {
        self.createdAt = createdAt
        self.imageData = imageData
        foodName = response.foodName
        calories = response.calories
        servingSize = response.servingSize
        foodDescription = response.description

        carbs = StoredNutrient(total: response.carbs.total, unit: response.carbs.unit)
        protein = StoredNutrient(total: response.protein.total, unit: response.protein.unit)
        fats = StoredNutrient(total: response.fats.total, unit: response.fats.unit)
        saturatedFats = StoredNutrient(total: response.saturatedFats.total, unit: response.saturatedFats.unit)
        polysaturatedFats = StoredNutrient(total: response.polyunsaturatedFats.total, unit: response.polyunsaturatedFats.unit)
        cholesterol = StoredNutrient(total: response.cholesterol.total, unit: response.cholesterol.unit)
        sodium = StoredNutrient(total: response.sodium.total, unit: response.sodium.unit)
        potassium = StoredNutrient(total: response.potassium.total, unit: response.potassium.unit)
        vitaminA = StoredNutrient(total: response.vitaminA.total, unit: response.vitaminA.unit)
        vitaminC = StoredNutrient(total: response.vitaminC.total, unit: response.vitaminC.unit)
        iron = StoredNutrient(total: response.iron.total, unit: response.iron.unit)
        calcium = StoredNutrient(total: response.calcium.total, unit: response.calcium.unit)
        fiber = StoredNutrient(total: response.fiber.total, unit: response.fiber.unit)
        sugar = StoredNutrient(total: response.sugar.total, unit: response.sugar.unit)
    }

    var image: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }

    struct StoredNutrient: Codable {
        let total: Double
        let unit: String
        var formatted: String {
            "\(total)\(unit)"
        }
    }
}
