//
//  WeatherService.swift
//  WeatherAPP
//
//  Lesson 2: owns URLs, HTTP, JSON decoding. ViewModel only asks for data.
//

import Foundation

enum WeatherError: LocalizedError {
    case cityNotFound
    case invalidResponse
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "City not found. Try another spelling."
        case .invalidResponse:
            return "Could not read weather data."
        case .network(let error):
            return error.localizedDescription
        }
    }
}


struct WeatherService: WeatherServiceProtocol {
    
    private var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
              !key.isEmpty,
              key != "your_key_here" else {
            fatalError("Missing OPENWEATHER_API_KEY. Copy Secrets.example.xcconfig → Secrets.xcconfig")
        }
        return key
    }
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    func fetch(city: String) async throws -> WeatherModel {
        //Build URL safety
        guard var components = URLComponents(string: "\(baseURL)/weather") else{
            throw WeatherError.invalidResponse
        }
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric") // ℃
            
        ]
        
        guard let url = components.url else{
            throw WeatherError.invalidResponse
        }
        
        //Fire the request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw WeatherError.network(error)
        }
        
        // 3. Check the HTTP status code
        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        switch http.statusCode {
        case 200: break                        // all good
        case 404: throw WeatherError.cityNotFound
        default:  throw WeatherError.invalidResponse
        }
        
        // 4. Decode JSON → WeatherModel
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(WeatherModel.self, from: data)
        } catch {
            throw WeatherError.invalidResponse
        }
        
    }
    
}

/*
 Always use URLComponents, never string interpolation
 A city name like "New York" would break a raw URL string — the space needs to be percent-encoded as %20. URLComponents handles all encoding automatically. Passing city names through queryItems means "São Paulo", "北京", and "Москва" all just work.
 
 4-step request pattern — memorise this
 Every network call you ever write follows the same four steps: build URL → fire request → check status code → decode response. The order matters. Decoding before checking the status code means you'd try to decode a 404 error page as your model and get a confusing crash.
 
 Map raw errors to typed WeatherError immediately
 URLSession throws raw system errors. We catch them at the source and re-throw as our own WeatherError cases. By the time the error reaches the ViewModel, it's always a WeatherError — no raw NSError strings, no guessing what went wrong.
 
 units=metric — offload work to the API
 Without this, the API returns temperature in Kelvin (300K = 27°C). Passing units=metric makes OpenWeatherMap return Celsius directly. Let the server do the conversion — your model and ViewModel stay simple. For Fahrenheit, use units=imperial.
 */


