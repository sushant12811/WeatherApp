//
//  WeatherModel.swift
//  WeatherAPP
//
//  Pure data types — no UI, no networking. Codable when mirroring JSON.
//

import Foundation

// Mirrors the OpenWeatherMap /weather endpoint exactly
struct WeatherModel: Codable {
    let name: String          // city name
    let main: MainWeather
    let weather: [WeatherCondition]
    let wind: Wind
}

struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double    // JSON: "feels_like" → auto-mapped
    let humidity: Int
    let tempMin: Double      // JSON: "temp_min"
    let tempMax: Double      // JSON: "temp_max"
}

struct WeatherCondition: Codable {
    let main: String         // "Clear", "Clouds", "Rain"
    let description: String  // "overcast clouds"
    let icon: String         // "04d" (for URL if needed)
}

struct Wind: Codable {
    let speed: Double        // metres per second
}

/*
 let not var in models
 Model data coming from an API should be immutable — once decoded, it doesn't change. Using let makes that explicit and prevents accidental mutation. If you need to update it, you decode a fresh model from a new API response.
 2
 Nested structs mirror nested JSON objects
 The JSON has "main": { "temp": 18.4 } — a nested object. Your Swift struct mirrors this exactly: a WeatherModel that contains a MainWeather struct. Codable recursively decodes nested types automatically — no extra code needed.
 3
 WeatherError: LocalizedError not just Error
 Conforming to LocalizedError and providing errorDescription means you can show error.localizedDescription directly in the UI — no switch statement needed in the View. The ViewModel's errorText(for:) catches these typed cases before they reach the View anyway.
 */
