//
//  NutritionSchema.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 08/12/25.
//

import Foundation

enum NutritionSchema {
    static let json = """
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
}
