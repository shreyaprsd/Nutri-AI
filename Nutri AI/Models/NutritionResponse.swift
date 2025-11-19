//
//  NutritionResponse.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 17/11/25.
//

import Foundation

struct NutritionResponse: Codable, Identifiable {
  var id = UUID()
  let foodName: String
  let calories: String
  let carbs: Nutrient
  let protein: Nutrient
  let fats: Nutrient
  let saturatedFats: Nutrient
  let polyunsaturatedFats: Nutrient
  let cholesterol: Nutrient
  let sodium: Nutrient
  let potassium: Nutrient
  let vitaminA: Nutrient
  let vitaminC: Nutrient
  let iron: Nutrient
  let calcium: Nutrient
  let fiber: Nutrient
  let sugar: Nutrient
  let servingSize: String
  let description: String

  struct Nutrient: Codable {
    let total: Double
    let unit: String

    var formatted: String {
      "\(total)\(unit)"
    }
  }

  enum CodingKeys: String, CodingKey {
    case foodName, calories, carbs, protein, fats, saturatedFats,
      polyunsaturatedFats, cholesterol, sodium, potassium, vitaminA,
      vitaminC, iron, calcium, fiber, sugar, servingSize, description
  }
}
