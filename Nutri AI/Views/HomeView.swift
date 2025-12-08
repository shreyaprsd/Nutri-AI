//
//  HomeView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 05/11/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Binding var selectedImage: UIImage?
    var analysisVM: NutrientAnalysisViewModel
    @Binding var hideFloatingButton: Bool

    var body: some View {
        NavigationStack {
            FoodEntryList(
                selectedImage: $selectedImage,
                analysisVM: analysisVM,
                hideFloatingButton: $hideFloatingButton
            )
        }
    }
}
