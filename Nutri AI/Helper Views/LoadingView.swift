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
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
        }
    }
}

struct LoadingFoodRow: View {
    let image: UIImage
    @Environment(\.appTheme) private var theme
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(theme.subtleCardBackground)
            .overlay {
                HStack {
                    LoadingImageView(image: image)
                    Spacer()
                    VStack(alignment: .leading, spacing: 4) {
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
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding(.horizontal, 4)
            .padding(8)
    }
}

#Preview {
    LoadingImageView(image: UIImage(systemName: "photo")!)
}
