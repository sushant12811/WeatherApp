//
//  ErrorCardView.swift
//  WeatherAPP
//
//  Created by Sushant Dhakal on 2026-05-26.
//
import SwiftUI
struct ErrorCardView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.body)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            Button("Try Again", action: retryAction)
                .buttonStyle(.bordered)
                .tint(.white)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }
}

#Preview {
    ErrorCardView(message: "Retry", retryAction:{} )
}
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle).foregroundStyle(.white.opacity(0.4))
            Text("Search for a city to see the weather")
                .font(.body).foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}
