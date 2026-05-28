//
//  WeatherCardView.swift
//  WeatherAPP
//
//  Lesson 3: reusable “hero” card — only displays strings passed in.
//

import SwiftUI

struct WeatherCardView: View {
    
    // Grabs vm from environment — no parameter needed
    @EnvironmentObject var viewModel: WeatherViewModel
    

    var body: some View {
        //Main Weather Display
        VStack(spacing: 0) {
            VStack(spacing: 8){
                Image(systemName: viewModel.weatherIcon)
                    .font(.system( size: 64))
                    .symbolRenderingMode(.multicolor)
                    .padding(.bottom,4)
                Text(viewModel.cityName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.8))
                Text(viewModel.temperatureText)
                    .font(.system(size: 64))
                    .foregroundStyle(.white)
                Text(viewModel.conditionText)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                
            }
            .padding(.vertical,24)
            Divider()
                .overlay(.white.opacity(0.2))
            //Stats row
            HStack{
                WeatherStateView(
                    icon:  "humidity.fill",
                    value: viewModel.humidityText,
                    label: "Humidity"
                )
                
                Divider()
                    .frame(height: 40)
                    .overlay(.white.opacity(0.2))
                WeatherStateView(
                    icon: "wind",
                    value: viewModel.windText,
                    label: "Wind"
                )
            }
            .padding(16)
        }
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 20))
        //Animate when data changes
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.spring(duration:0.4), value: viewModel.temperatureText)
        
    }
}

// Tiny reusable stat cell — stays in the same file

struct WeatherStateView: View{
    let icon: String
    let value: String
    let label: String
    
    var body: some View{
        VStack(spacing: 4){
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
#Preview {
    WeatherCardView()
        .environmentObject(WeatherViewModel())
}

/*
 The View only uses ViewModel's computed properties
 Every Text() here calls vm.temperatureText, vm.conditionText, vm.weatherIcon — all pre-formatted strings from the ViewModel. The View has zero logic. If the format changes, you fix it in one place in the ViewModel, not across multiple views.
 2
 .symbolRenderingMode(.multicolor) — one line magic
 SF Symbols like cloud.rain.fill have built-in colour layers. Adding .symbolRenderingMode(.multicolor) activates them — you get a blue cloud with falling raindrops automatically. No custom images, no asset catalogue entries needed.
 3
 .animation(.spring, value:) — targeted animation
 Animating on value: vm.temperatureText means the spring animation only fires when the temperature changes — not on every state update. Never use .animation() without a value: parameter — it animates everything and causes visual glitches.
 */
