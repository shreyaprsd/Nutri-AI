//
//  FoodEntryList.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 20/11/25.
//

import SwiftData
import SwiftUI

struct FoodEntryList: View {
    @Query(sort: \NutritionModel.createdAt, order: .reverse) var foodEntries:
        [NutritionModel]
    @Binding var selectedImage: UIImage?
    @State private var geminiVM = GeminiViewModel()
    @State private var imageID = UUID()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            if foodEntries.isEmpty {
                FoodEntryEmptyList()
            } else {
                ForEach(foodEntries) { entry in
                    FoodEntryRow(item: entry)
                        .frame(width: 290, height: 105)
                        .padding(6)
                        .padding(.top, 478)
                        .padding(.bottom, 116)
                }
            }
        }
    }
}

struct FoodEntryEmptyList: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(Color.gray.opacity(0.2))
                .overlay {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("You haven't uploaded any food")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text(
                            "Start tracking today's meals by taking a quick picture."
                        )
                    }
                }
                .frame(width: 290, height: 105)
                .padding(6)
                .padding(.top, 478)
                .padding(.bottom, 116)
        }
    }
}

struct FoodEntryRow: View {
    let item: NutritionModel
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.gray.opacity(0.2))
            .overlay {
                if let image = item.image {
                    FoodImage(image: image)
                    VStack {
                        HStack {
                            Text(item.foodName)
                            Text(item.createdAt, style: .time)
                        }
                        FoodNutriView(
                            nutrition: "\(item.calories) kCal",
                            image: "🔥"
                        )
                        HStack {
                            FoodNutriView(
                                nutrition: item.protein.formatted,
                                image: "🍗"
                            )
                            FoodNutriView(
                                nutrition: item.carbs.formatted,
                                image: "🌾"
                            )
                            FoodNutriView(
                                nutrition: item.fats.formatted,
                                image: "🥑"
                            )
                        }
                    }
                }
            }
    }
}
