//
//  ContentView.swift
//  Project-4-BetterRest
//
//  Created by Sheikh Bayazid on 2/19/21.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var wakeUp: Date = defaultWakeTime
    @State private var sleepAmount = 7.0
    @State private var coffeeAmount = 1
    // alerts
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("Time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Desire sleep amount?")) {
                    Stepper("\(sleepAmount, specifier: "%g") hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                
                Section(header: Text("Daily coffee intake?")) {
                    Stepper(value: $coffeeAmount, in: 1...20) {
                        if coffeeAmount == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeeAmount) cups")
                        }
                    }
                }
                
                Button(action: calculateBedtime, label: {
                    Text("Calculate")
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                })
                
            }.navigationTitle("Better Rest")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    
    
    //MARK: - Calculation
    func calculateBedtime() {
        guard let model = try? SleepCalculator(configuration: MLModelConfiguration()) else { fatalError("CoreML error") }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(sleepAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your Sleep Time!".uppercased()
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            print("CoreML error: \(error.localizedDescription)")
        }
        
        self.showingAlert = true
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



//var components = DateComponents()
//components.hour = 8
//components.minute = 0
//let setDate = Calendar.current.date(from: components) ?? Date()
//
//
//return VStack {
//    Form {
//        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
//            Text("\(sleepAmount, specifier: "%g") hours").bold()
//        }
//
//        DatePicker("Date", selection: $wakeUp, in: Date()...)
//    }
//}
