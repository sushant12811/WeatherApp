//
//  WeatherViewModel.swift
//  WeatherAPP
//
//  Lesson 1 (App 2): state + logic. Views observe @Published and call methods.
//

import Combine
import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var cityName = "Toronto"

    private let service:  WeatherServiceProtocol

    init(service:  WeatherServiceProtocol = WeatherService()) {
        self.service = service
    }

    func fetchWeather() {
        let trimmed = cityName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a city name."
            return
        }

        Task {
            isLoading = true
            errorMessage = nil
            do {
                weather = try await service.fetch(city: trimmed)
            } catch {
                errorMessage = errorText(for: error)
                weather = nil
            }
            isLoading = false
        }
    }

    // MARK: - Display-ready strings (View stays dumb)

    var temperatureText: String {
        guard let temperature = weather?.main.temp else {return "--"}
        return "\(Int(temperature.rounded()))°C"
    }

    var conditionText: String {
        weather?.weather.first?.description.capitalized ?? "--"
    }
    
    var humidityText: String {
        guard let h = weather?.main.humidity else { return "--" }
            return "\(h)%"
        }


    var windText: String {
            guard let w = weather?.wind.speed else { return "--" }
            return "\(Int(w)) m/s"
        }

        var weatherIcon: String {
            switch weather?.weather.first?.main.lowercased() {
            case "clear":     return "sun.max.fill"
            case "clouds":    return "cloud.fill"
            case "rain":      return "cloud.rain.fill"
            case "snow":      return "cloud.snow.fill"
            case "thunderstorm": return "cloud.bolt.fill"
            default:         return "cloud.sun.fill"
            }
        }
    
    private func errorText(for error: Error) -> String {
        error.localizedDescription
    }
}
