//
//  ContentView.swift
//  BetterRest
//
//  Created by Victor Colen on 28/11/21.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertDesc = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 30
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 0) {
                Text("When do you want do wake up?")
                    .font(.headline)
                
                DatePicker("Enter the desired time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 0) {
                Text("Desired amount of sleep")
                        .font(.headline)
                Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack (alignment: .leading, spacing: 0) {
                Text("Daily coffee intake")
                        .font(.headline)
                Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button ("Calculate", action: calculateSleep)
            }
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("Dismiss") { }
        } message: {
            Text(alertDesc)
        }
    }
        
    
    func calculateSleep() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 3600
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUpTime -  prediction.actualSleep
            
            alertTitle = "You ideal bedtime is..."
            alertDesc = "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            alertTitle = "Oops..."
            alertDesc = "Sorry, something went wrong on our end"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
