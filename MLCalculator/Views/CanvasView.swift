//
//  CanvasView.swift
//  MLCalculator
//
//  Created by Eli Hartnett on 11/13/22.
//

import SwiftUI

struct CanvasView: View {
    
    @ObservedObject var calculatorModel: CalculatorModel
    @Binding var currentLine: Line
    @Binding var lines: [Line]
    
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .default).autoconnect()
    @State var currentTime = 0.0
    @State var lastLineTime = 0.0
    
    var body: some View {
        
        Canvas { context, size in
            var path = Path()
            path.addLines(currentLine.points)
            
            if !lines.isEmpty {
                for line in lines {
                    path.addLines(line.points)
                }
            }
            
            context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
        }
        .background(.white)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged({ value in
                currentLine.points.append(value.location)
            })
                .onEnded({ value in
                    currentLine.points.append(value.location)
                    lines.append(currentLine)
                    currentLine.points = []
                    lastLineTime = currentTime
                })
        )
        .onReceive(timer) { _ in
            currentTime += 0.1
            if (currentTime - lastLineTime > 1) && !lines.isEmpty {
                if var result = calculatorModel.predict() {
                    switch result {
                    case "add":
                        result = "+"
                    case "sub":
                        result = "-"
                    case "mul":
                        result = "x"
                    case "div":
                        result = "÷"
                    case "dec":
                        result = "."
                    case "eq":
                        result = "="
                    default:
                        break
                    }
                    withAnimation {
                        calculatorModel.problemString.append(result)
                    }
                    if result == "=" {
                        calculatorModel.solveProblem()
                    }
                }
            }
        }
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(calculatorModel: CalculatorModel(), currentLine: .constant(Line()), lines: .constant([]))
            .environmentObject(CalculatorModel())
    }
}
