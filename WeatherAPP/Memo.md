# Weather (MVVM)
Views talk to ViewModel only
Logic lives in ViewModel
Service handles networking
Scales to any sized app

## Why a Services layer?
The ViewModel shouldn't know how data is fetched — only that it can ask for it. WeatherService owns all the URL construction, HTTP calls, and JSON decoding. Swap the API provider later and only WeatherService changes — nothing else.

In App 1(Habit tracker), your Views held @State and did a little logic. That's fine for small apps. The moment you add networking, that falls apart — you'd end up with 200-line Views full of URL code and error handling. MVVM draws a hard line: Views render, ViewModels think.
@ObservableObject + @Published is MVVM's version of @State + @Binding from App 1, but across a class boundary. The mental model is the same — state changes trigger redraws — just now the state lives in a separate object that multiple views can share.
Notice what the ViewModel does NOT have — no import SwiftUI, no Text(), no VStack. It's pure logic. You could run and test every single method without a simulator. That's the point.

                                            View
                                        ContentView
                                        WeatherCardView
                                        ForecastRowView
                                    observes @Published
                                              ↕
                                        calls fetchWeather()
                                            ViewModel
                                         WeatherViewModel
                                            @ObservableObject
                                        owns state + logic
                                        passes decoded data
                                               ↕
                                        calls fetch(city:)
                                        Model + Service
                                        WeatherModel (Codable)
                                        WeatherService (URLSession)
                                        pure data, no UI


The View's one rule: be dumb
A View in MVVM has zero logic. It reads @Published properties from the ViewModel and calls its functions. It never constructs a URL, never decodes JSON, never decides what data to show. If you see an if/else in a View that's about data logic — that belongs in the ViewModel.

The ViewModel's job: prepare data for display
The ViewModel takes raw API data (temperature in Kelvin, Unix timestamps) and converts it to display-ready strings ("22°C", "Monday"). The View just renders whatever strings the ViewModel provides — it never does formatting itself.

MVVM is the most common architecture question in iOS interviews. The answer they want: "The View observes the ViewModel via @ObservableObject. The ViewModel exposes @Published properties and handles business logic. The Model is pure data." Say that confidently and you're ahead of 70% of candidates.


# Interview Question: 
The View observes the ViewModel via ObservableObject and @Published. The ViewModel handles business logic and formatting. The Model is pure data. The Service fetches and decodes from the API.”


##Why not just use @State for the ViewModel?
@State is for value types (structs). WeatherViewModel is a class — a reference type. @StateObject is designed specifically for ObservableObject classes: it holds a stable reference and subscribes to @Published changes so the View redraws when data arrives.

##@StateObject vs @ObservedObject
This trips up almost every junior developer. @StateObject — the View owns the ViewModel, creates it once, never recreates it on redraw. @ObservedObject — the View watches a ViewModel someone else created and passed in. Wrong choice = ViewModel recreated every redraw = data wiped randomly.

##@EnvironmentObject — implicit dependency
Instead of passing vm as a parameter through every child view, you inject it once at the top with .environmentObject(vm). Any descendant view that needs it declares @EnvironmentObject var vm: WeatherViewModel and SwiftUI finds it automatically. No prop drilling.

##Crash if you forget .environmentObject()
If a child view declares @EnvironmentObject but no ancestor injected it, the app crashes at runtime with "No ObservableObject found." Always inject at the top of the view tree — or in the #Preview macro when testing child views in isolation.

// ── ContentView.swift ──────────────────────────────
@StateObject private var vm = WeatherViewModel() // OWNER

var body: some View {
    WeatherCardView()
        .environmentObject(vm)   // inject into tree
}

// ── WeatherCardView.swift ──────────────────────────
@EnvironmentObject var vm: WeatherViewModel // READER
// No parameter in init — SwiftUI finds it automatically

// ── #Preview — always inject manually ─────────────
#Preview {
    WeatherCardView()
        .environmentObject(WeatherViewModel(
            service: MockWeatherService()  // no real API in previews
        ))
}


The complete property wrapper cheat sheet
@State
— owns a value type (struct/enum) in a View
@Binding
— borrows a reference to parent's @State
@StateObject
— owns a reference type (class) in a View
@ObservedObject
— watches a class passed in from outside
@EnvironmentObject
— reads a class injected into the environment
@Environment
— reads system values (dismiss, colorScheme…)

#When to use @EnvironmentObject vs passing directly
Pass directly (@ObservedObject) when: only one child needs the ViewModel, or the dependency is obvious from the init. Use @EnvironmentObject when: many views across different levels need it, or passing it through intermediate views that don't use it would be noise.

#Interview answer: complete MVVM + property wrappers
"ContentView owns the ViewModel via @StateObject and injects it with .environmentObject(). Child views subscribe via @EnvironmentObject — no prop drilling. The ViewModel exposes @Published properties; children redraw automatically when they change. Logic stays in the ViewModel, Views stay dumb."


##MVVM
✓Architecture pattern
Model owns data. ViewModel prepares it. View renders it. Zero logic in views.

##@ObservableObject
Observable class
The class protocol that lets SwiftUI subscribe to a ViewModel's changes.

##@Published
✓Class-level state
Marks a property to broadcast changes to all observing views automatically.

#@StateObject
✓ViewModel owner
Creates and owns an ObservableObject. Stable across view redraws.

#@EnvironmentObject
✓No prop drilling
Reads an injected ViewModel from anywhere in the view tree.

#async / await
✓Modern concurrency
Write async network code that reads like synchronous code. No callbacks.

#URLSession
✓HTTP networking
Apple's built-in HTTP client. data(from:) + Codable = complete API layer.

#Protocol + Mock
✓Dependency injectionNEW
Swap real vs mock service via init. Testable, previewable, decoupled.

#Stretch goals for this app
📍
CoreLocation — use the device's actual location
Add CLLocationManager to the ViewModel. Request permission, get lat/lon, call the API's coordinate endpoint. Directly applicable to App 5 (Fitness Tracker).
📅
5-day forecast — second API endpoint
Hit the /forecast endpoint alongside /weather. Model the response, add a ForecastRowView. Practice building a second network call inside the same ViewModel.
🏙️
Saved cities — combine with App 1's persistence
Store recently searched cities in UserDefaults (you already know how). Show them as quick-access chips above the search bar. Combines everything from both apps.
🧪
Unit tests for the ViewModel
Add an XCTest target. Inject MockWeatherService and test that temperatureText, weatherIcon, and error states all produce the right values. The protocol you built makes this trivial.
