//
//  ContentView.swift
//  MLCalculator
//
//  Created by Eli Hartnett on 11/13/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var calculatorModel = CalculatorModel()
    
    var body: some View {
        VStack {
            
            HStack {
                
                Text(calculatorModel.problemStringLabel)
                
                Spacer()
                
                Button {
                    if !calculatorModel.problemString.isEmpty {
                        calculatorModel.problemString.removeLast()
                    }
                } label: {
                    Image(systemName: "delete.left")
                }
                .disabled(calculatorModel.problemString.isEmpty)
                .animation(.default, value: calculatorModel.problemString)
            }
            .overlay {
                if calculatorModel.problemString.isEmpty {
                    Text("Draw a number to start!")
                }
            }
            .padding()
            
            Spacer()
            
            GeometryReader { proxy in
                CanvasView(calculatorModel: calculatorModel, currentLine: $calculatorModel.currentLine, lines: $calculatorModel.lines)
                    .border(.primary)
                    .onAppear {
                        calculatorModel.size = proxy.size
                    }
            }
        }
        .alert(calculatorModel.alertTitle, isPresented: $calculatorModel.showAlert, actions: {
            Button("Reset", role: .destructive) { }
            Button("Keep value", role: .cancel) {
                calculatorModel.problemString.append(calculatorModel.result.formatted())
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CalculatorModel())
    }
}
