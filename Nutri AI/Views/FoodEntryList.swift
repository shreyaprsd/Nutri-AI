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
                List {
                    ForEach(foodEntries, id: \.id) { entry in
                        FoodEntryRow(item: entry)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)
            }
        }
    }
}

struct FoodEntryEmptyList: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.gray.opacity(0.1))
            .overlay {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You haven't uploaded any food yet.")
                        .font(.callout)
                        .bold()
                    Text(
                        "Start tracking today's meals by taking a quick picture."
                    )
                }
            }
            .frame(width: 330, height: 120)
            .padding(8)
            .padding(.top, 478)
            .padding(.bottom, 116)
    }
}

struct FoodEntryRow: View {
    let item: NutritionModel
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.gray.opacity(0.1))
            .overlay {
                HStack {
                    if let image = item.image {
                        FoodImage(image: image)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(item.foodName)
                                .fontWeight(.regular)
                                .font(.system(size: 16))
                            Spacer()
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .overlay {
                                    Text(item.createdAt, style: .time)
                                        .fontWeight(.regular)
                                        .font(.system(size: 12))
                                }
                                .frame(width: 54, height: 28)
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("\(item.calories) calories")
                        }
                        .bold()
                        Spacer()
                        HStack {
                            FoodNutriView(nutrition: item.protein.roundedFormatted, image: "🍗")

                            FoodNutriView(nutrition: item.carbs.roundedFormatted, image: "🌾")

                            FoodNutriView(nutrition: item.fats.roundedFormatted, image: "🥑")
                        }
                    }
                    .padding(.top)
                    .padding(.bottom)
                    .padding()
                }
            }
            .frame(width: 330, height: 120)
            .padding(8)
//            .padding(.top, 478)
//            .padding(.bottom, 116)
    }
}

#Preview {
    FoodEntryEmptyList()
}
