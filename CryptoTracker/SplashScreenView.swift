//
//  SplashScreenView.swift
//  CryptoTracker
//
//  Created by Javier Martin on 23/12/24.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Fondo de la pantalla de carga
            Color.black
                .ignoresSafeArea()

            VStack {
                // Logo o icono de la app
                Image(systemName: "bitcoinsign.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.yellow)
                    .opacity(isAnimating ? 1.0 : 0.5)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text("CryptoTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SplashScreenView()
}
