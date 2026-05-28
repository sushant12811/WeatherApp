//
//  ContentView.swift
//  WeatherAPP
//
//  Lesson 3: root screen — search, loading, errors, child views.
//

import SwiftUI

struct ContentView: View {
    // Owns the ViewModel — lives as long as this view
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                

                ScrollView {
                    VStack(spacing: 24) {
                        searchBar
                        stateView
                       
                    }
                    .padding()
                }
            }
        // Inject vm into the environment for all children
            .environmentObject(viewModel)
            

            
        }
    // Computed view — keeps body clean and readable
    @ViewBuilder
    private var stateView: some View{
        if viewModel.isLoading{
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        } else if let error = viewModel.errorMessage {
            ErrorCardView(message: error) { viewModel.fetchWeather() }
        } else if viewModel.weather != nil {
            WeatherCardView()
        } else {
            EmptyStateView()
        }
    }

    private var backgroundGradient: some View {
            LinearGradient(
                colors: [Color(.darkBlue), Color(.lightBlue)],
                startPoint: .top, endPoint: .bottom)
        }

    private var searchBar: some View {
        HStack {
                    TextField("Search city...", text: $viewModel.cityName)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .onSubmit { viewModel.fetchWeather() }

                    Button(action: viewModel.fetchWeather) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.white)
                    }
                }
                .padding(12)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 12))
    }

    
}

#Preview {
    ContentView()
}

/*
 @ViewBuilder — conditional views cleanly
 stateView uses @ViewBuilder to return different views based on state — loading spinner, error card, weather card, or empty state. Extracting this into a computed property keeps body short and each state easy to find and edit independently.
 2
 $vm.cityName — binding into the ViewModel
 The TextField binds directly to vm.cityName — a @Published property. When the user types, cityName updates live. When they hit Search, fetchWeather() reads the current value. No local @State string needed.
 3
 Extracting sub-views as computed properties
 searchBar and backgroundGradient are private var computed properties — not separate files. Use this for views that are only used once and too small to deserve their own file. The rule: if it's reused or complex, make it a file. If it's local and simple, make it a computed property.
 */
