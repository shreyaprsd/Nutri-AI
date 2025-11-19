//
//  NutritionResponseView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 18/11/25.
//

import SwiftUI

struct NutritionResponseView: View {
    @Binding var selectedImage: UIImage?
    var nutri: NutritionResponse
    var body: some View {
        HStack {
//            if let image = selectedImage {}

            Text(nutri.foodName)
        }
    }
}
