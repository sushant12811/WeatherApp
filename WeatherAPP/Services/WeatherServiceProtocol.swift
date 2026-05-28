//
//  WeatherServiceProtocol.swift
//  WeatherAPP
//
//  Created by Sushant Dhakal on 2026-05-25.
//

import Foundation

// The contract — what any weather service must do
protocol WeatherServiceProtocol {
    func fetch(city: String) async throws -> WeatherModel
}

// Real implementation — hits the live API
// (WeatherService already shown in previous tab)

// Mock — returns instant fake data for testing
struct MockWeatherService: WeatherServiceProtocol {
    func fetch(city: String) async throws -> WeatherModel {
        // Simulates network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        return WeatherModel(
            name: city,
            main: MainWeather(
                temp: 22.0, feelsLike: 21.0,
                humidity: 60, tempMin: 18.0, tempMax: 25.0
            ),
            weather: [WeatherCondition(
                main: "Clear",
                description: "clear sky",
                icon: "01d"
            )],
            wind: Wind(speed: 3.5)
        )
    }
}

// Mock that always fails — test your error UI
struct FailingWeatherService: WeatherServiceProtocol {
    func fetch(city: String) async throws -> WeatherModel {
        throw WeatherError.cityNotFound
    }
}

/*
 The protocol is the most important file in this lesson
 The ViewModel depends on WeatherServiceProtocol, not on WeatherService. This means the ViewModel is completely decoupled from the network layer. You can swap real → mock → different API provider by passing a different conforming type — nothing in the ViewModel changes.
 2
 MockWeatherService — develop without network
 During UI development you want instant, predictable data — not a real API call that might be slow or fail. WeatherViewModel(service: MockWeatherService()) gives you reliable data instantly. Use it in SwiftUI Previews so they render without hitting the network.
 3
 FailingWeatherService — test your error states
 Most developers only test the happy path and ship broken error UIs. FailingWeatherService lets you instantly test what your error banner looks like without needing to type a fake city name. Always test your error state — users will hit it.
 4
 Interview answer: "How would you test this?"
 "I define a WeatherServiceProtocol and inject it into the ViewModel via init. In tests I pass a MockWeatherService that returns controlled data synchronously. This means I can unit test all ViewModel logic — loading state, error handling, formatted strings — without any network dependency."


 */
