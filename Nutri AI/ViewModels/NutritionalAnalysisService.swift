//
//  NutritionalAnalysisService.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import FirebaseAI
import FirebaseAILogic
import UIKit

protocol NutritionalAnalysisServiceProtocol {
    func analyze(image: UIImage) async throws -> NutritionResponse
}

final class NutritionalAnalysisService: NutritionalAnalysisServiceProtocol {
    private let model: GenerativeModel
    init() {
        let ai = FirebaseAI.firebaseAI()
        model = ai.generativeModel(modelName: "gemini-2.5-flash",
                                   generationConfig: GenerationConfig(responseMIMEType: "application/json"))
    }

    func analyze(image: UIImage) async throws -> NutritionResponse {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NutritionAnalysisError.imageConversionFailed
        }
        let imagePart = InlineDataPart(data: imageData, mimeType: "image/jpeg")
        let prompt = Self.buildPrompt()
        let promptPart = TextPart(prompt)

        let response = try await model.generateContent(promptPart, imagePart)

        guard let text = response.text, let json = text.data(using: .utf8) else {
            throw NutritionAnalysisError.invalidResponse
        }
        return try JSONDecoder().decode(NutritionResponse.self, from: json)
    }

    private static func buildPrompt() -> String {
        """
        You are a nutritional analysis expert. Based on the provided image, identify the food item(s) and estimate their nutritional information for a standard serving size.Provide the macronutrients and micronutrients in grams or miligrams only(represented by g and mg respectively). Respond ONLY with a JSON object that conforms to the provided schema. Do not include any other text, markdown formatting, or explanations.Also note that the description and foodName provided should not be more than 5 and 3 words respectively, calories should not represented with kCal in the json data.
           

        Schema: \(NutritionSchema.json)
        """
    }
}

enum NutritionAnalysisError: LocalizedError {
    case imageConversionFailed
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            "Failed to convert image to data"
        case .invalidResponse:
            "Failed to parse response from AI model"
        }
    }
}
