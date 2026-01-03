//
//  GeminiViewModel.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 17/11/25.
//

import FirebaseAI
import FirebaseAILogic
import Observation
import SwiftData
import SwiftUI
import UIKit

@Observable
class GeminiViewModel {
    var isLoading: Bool = false
    var nutritionInfo: NutritionResponse?

    private var model: GenerativeModel = {
        let ai = FirebaseAI.firebaseAI()
        return ai.generativeModel(
            modelName: "gemini-2.5-flash",
            generationConfig: GenerationConfig(responseMIMEType: "application/json")
        )
    }()

    static let nutritionSchema = """
    {
      "type": "object",
      "required": ["foodName", "calories", "carbs", "protein", "fats", "saturatedFats", "polyunsaturatedFats", "cholesterol", "sodium", "potassium", "vitaminA", "vitaminC", "iron", "calcium", "fiber", "sugar", "servingSize", "description"],
      "properties": {
        "foodName": { "type": "string" },
        "calories": { "type": "string" },
        "carbs": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "protein": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "fats": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "saturatedFats": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "polyunsaturatedFats": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "cholesterol": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "sodium": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "potassium": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "vitaminA": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "vitaminC": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "iron": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "calcium": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "fiber": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "sugar": {
          "type": "object",
          "properties": {
            "total": { "type": "number" },
            "unit": { "type": "string" }
          }
        },
        "servingSize": { "type": "string" },
        "description": { "type": "string" }
      }
    }
    """
    @MainActor
    func analyzeFood(image: UIImage, modelContext: ModelContext) async {
        isLoading = true
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Failed to convert image to data")
                isLoading = false
                return
            }
            let imagePart = InlineDataPart(data: imageData, mimeType: "image/jpeg")
            let prompt = """
            You are a nutritional analysis expert. Based on the provided image, identify the food item(s) and estimate their nutritional information for a standard serving size.Provide the macronutrients and micronutrients in grams or miligrams only(represented by g and mg respectively). Respond ONLY with a JSON object that conforms to the provided schema. Do not include any other text, markdown formatting, or explanations.Also note that the description and foodName provided should not be more than 5 and 3 words respectively, calories should not represented with kCal in the json data.
               

            Schema: \(Self.nutritionSchema)
            """
            let promptPart = TextPart(prompt)
            let response = try await model.generateContent(promptPart, imagePart)
            guard let text = response.text, let jsonData = text.data(using: .utf8) else {
                print("Failed to get the text from the data response ")
                isLoading = false
                return
            }
            print(text)
            let decoder = JSONDecoder()
            nutritionInfo = try decoder.decode(NutritionResponse.self, from: jsonData)

            if let nutritionInfo {
                let entry = NutritionModel(createdAt: Date(), imageData: imageData, response: nutritionInfo)
                let vm = NutritionVM(modelContext: modelContext)
                try await vm.addFoodEntry(entry)
            }
            isLoading = false
        } catch {
            print(error.localizedDescription)
            isLoading = false
        }
    }
}
