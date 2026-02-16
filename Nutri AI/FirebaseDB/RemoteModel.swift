//
//  RemoteModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

struct RemoteModel: Codable, Identifiable {
    @DocumentID var id: String?
    var createdAt: Timestamp
    var foodImageURL: String?
    var foodName: String
    var servingSize: String
    var foodDescription: String
    var servingMultiplier: Double
    var nutrients: NutrientsData

    struct NutrientsData: Codable {
        var calories: String
        var carbs: RemoteNutrient
        var protein: RemoteNutrient
        var fats: RemoteNutrient
        var saturatedFats: RemoteNutrient
        var polyunsaturatedFats: RemoteNutrient
        var cholesterol: RemoteNutrient
        var sodium: RemoteNutrient
        var potassium: RemoteNutrient
        var vitaminA: RemoteNutrient
        var vitaminC: RemoteNutrient
        var iron: RemoteNutrient
        var calcium: RemoteNutrient
        var fiber: RemoteNutrient
        var sugar: RemoteNutrient

        enum CodingKeys: String, CodingKey {
            case calories
            case carbs
            case protein
            case fats
            case saturatedFats = "saturated_fats"
            case polyunsaturatedFats = "polyunsaturated_fats"
            case cholesterol
            case sodium
            case potassium
            case vitaminA = "vitamin_a"
            case vitaminC = "vitamin_c"
            case iron
            case calcium
            case fiber
            case sugar
        }
    }

    struct RemoteNutrient: Codable {
        let total: Double
        let unit: String

        var formatted: String {
            "\(total)\(unit)"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_At"
        case foodImageURL = "food_image_url"
        case foodName = "food_name"
        case servingSize = "serving_size"
        case foodDescription = "food_description"
        case servingMultiplier = "serving_multiplier"
        case nutrients
    }

    init(model: NutritionModel, imageURL: String?) {
        id = model.id.uuidString
        createdAt = Timestamp(date: model.createdAt)
        foodImageURL = imageURL
        foodName = model.foodName
        servingSize = model.servingSize
        foodDescription = model.foodDescription
        servingMultiplier = model.servingMultiplier

        nutrients = NutrientsData(
            calories: model.nutrients.calories,
            carbs: RemoteNutrient(total: model.nutrients.carbs.total, unit: model.nutrients.carbs.unit),
            protein: RemoteNutrient(total: model.nutrients.protein.total, unit: model.nutrients.protein.unit),
            fats: RemoteNutrient(total: model.nutrients.fats.total, unit: model.nutrients.fats.unit),
            saturatedFats: RemoteNutrient(total: model.nutrients.saturatedFats.total, unit: model.nutrients.saturatedFats.unit),
            polyunsaturatedFats: RemoteNutrient(total: model.nutrients.polyunsaturatedFats.total, unit: model.nutrients.polyunsaturatedFats.unit),
            cholesterol: RemoteNutrient(total: model.nutrients.cholesterol.total, unit: model.nutrients.cholesterol.unit),
            sodium: RemoteNutrient(total: model.nutrients.sodium.total, unit: model.nutrients.sodium.unit),
            potassium: RemoteNutrient(total: model.nutrients.potassium.total, unit: model.nutrients.potassium.unit),
            vitaminA: RemoteNutrient(total: model.nutrients.vitaminA.total, unit: model.nutrients.vitaminA.unit),
            vitaminC: RemoteNutrient(total: model.nutrients.vitaminC.total, unit: model.nutrients.vitaminC.unit),
            iron: RemoteNutrient(total: model.nutrients.iron.total, unit: model.nutrients.iron.unit),
            calcium: RemoteNutrient(total: model.nutrients.calcium.total, unit: model.nutrients.calcium.unit),
            fiber: RemoteNutrient(total: model.nutrients.fiber.total, unit: model.nutrients.fiber.unit),
            sugar: RemoteNutrient(total: model.nutrients.sugar.total, unit: model.nutrients.sugar.unit)
        )
    }

    func toNutritionModel() -> NutritionModel {
        let response = NutritionResponse(
            foodName: foodName,
            calories: nutrients.calories,
            carbs: NutritionResponse.Nutrient(
                total: nutrients.carbs.total,
                unit: nutrients.carbs.unit
            ),
            protein: NutritionResponse.Nutrient(
                total: nutrients.protein.total,
                unit: nutrients.protein.unit
            ),
            fats: NutritionResponse.Nutrient(
                total: nutrients.fats.total,
                unit: nutrients.fats.unit
            ),
            saturatedFats: NutritionResponse.Nutrient(
                total: nutrients.saturatedFats.total,
                unit: nutrients.saturatedFats.unit
            ),
            polyunsaturatedFats: NutritionResponse.Nutrient(
                total: nutrients.polyunsaturatedFats.total,
                unit: nutrients.polyunsaturatedFats.unit
            ),
            cholesterol: NutritionResponse.Nutrient(
                total: nutrients.cholesterol.total,
                unit: nutrients.cholesterol.unit
            ),
            sodium: NutritionResponse.Nutrient(
                total: nutrients.sodium.total,
                unit: nutrients.sodium.unit
            ),
            potassium: NutritionResponse.Nutrient(
                total: nutrients.potassium.total,
                unit: nutrients.potassium.unit
            ),
            vitaminA: NutritionResponse.Nutrient(
                total: nutrients.vitaminA.total,
                unit: nutrients.vitaminA.unit
            ),
            vitaminC: NutritionResponse.Nutrient(
                total: nutrients.vitaminC.total,
                unit: nutrients.vitaminC.unit
            ),
            iron: NutritionResponse.Nutrient(
                total: nutrients.iron.total,
                unit: nutrients.iron.unit
            ),
            calcium: NutritionResponse.Nutrient(
                total: nutrients.calcium.total,
                unit: nutrients.calcium.unit
            ),
            fiber: NutritionResponse.Nutrient(
                total: nutrients.fiber.total,
                unit: nutrients.fiber.unit
            ),
            sugar: NutritionResponse.Nutrient(
                total: nutrients.sugar.total,
                unit: nutrients.sugar.unit
            ),
            servingSize: servingSize,
            description: foodDescription
        )

        let date = createdAt.dateValue()
        let imageData: Data? = nil

        let model = NutritionModel(
            createdAt: date,
            imageData: imageData,
            response: response
        )
        // Preserve the Firestore document id to avoid duplicate local entries on sync.
        if let id, let uuid = UUID(uuidString: id) {
            model.id = uuid
        }
        model.servingMultiplier = servingMultiplier

        return model
    }
}
