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
    
    private var idealBedTime: String {
        calculateSleep()
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 6
        components.minute = 30
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        Text("When do you want do wake up?")
                            .font(.headline)
                        
                        DatePicker("Enter the desired time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Section {
                        Text("Desired amount of sleep")
                            .font(.headline)
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    Section {
                        Text("Daily coffee intake")
                            .font(.headline)
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(1..<21, id: \.self) {
                                Text("\($0) cups")
                            }
                            
                        }
                    }
                    .navigationTitle("BetterRest")
                    
                }
                
                
                Text("Your ideal bedtime is \(idealBedTime)")
                    .font(.title)
            }
        }
    }
    
    
    func calculateSleep() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 3600
            let minutes = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUpTime -  prediction.actualSleep
            
            return "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            return "Oops... Something went wrong on our end."
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
