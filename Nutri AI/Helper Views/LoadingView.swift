//
//  LoadingView.swift
//  Nutri AI
//
//  Created by Shreya Prasad on 25/11/25.
//

import SwiftUI

struct LoadingImageView: View {
    let image: UIImage
    var isLoading = true
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 116, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .blur(radius: isLoading ? 1 : 0)
                .overlay {
                    if isLoading {
                        AnalysisProgressView()
                    }
                }
        }
    }
}

struct LoadingFoodRow: View {
    let image: UIImage
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(Color.gray.opacity(0.1))
            .overlay {
                HStack {
                    LoadingImageView(image: image)
                    VStack(alignment: .leading, spacing: 4) {
                        Spacer()
                        Text("Analyzing food...")
                            .fontWeight(.regular)
                            .font(.system(size: 16))
                            .bold()
                        
                        Spacer()
                        
                        Text("We'll notify you when done!")
                            .foregroundStyle(Color.secondary)
                            .fontWeight(.regular)
                            .font(.system(size: 12))
                    }
                    .padding(.top)
                    .padding(.bottom)
                    .padding()
                }
            }
            .frame(width: 330, height: 120)
            .padding(8)
    }
}

#Preview {
    LoadingImageView(image: UIImage(systemName: "photo")!)
}
