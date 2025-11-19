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
  @State private var geminiVM = GeminiViewModel()
  @State private var imageID = UUID()

  var body: some View {
    Group {
      if let selectedImage {
        VStack {
          Image(uiImage: selectedImage)
            .resizable()
            .scaledToFit()
            .frame(width: 300, height: 300)
            .padding()
        }
        .task(id: imageID) {
          print("New image detected, starting analysis...")
          await geminiVM.analyzeFood(image: selectedImage)
          print(geminiVM.nutritionInfo ?? "no data")
        }
      } else {
        Text("hello")
      }
    }
    .onChange(of: selectedImage) { _, newValue in
      if newValue != nil {
        imageID = UUID()
        print(" Image changed, new ID generated")
      }
    }
  }
}
