//
//  CalculatorModel.swift
//  MLCalculator
//
//  Created by Eli Hartnett on 11/13/22.
//

import Foundation
import CoreML
import SwiftUI

class CalculatorModel: ObservableObject {
    
    @Published var showAlert = false
    @Published var alertTitle = ""
    
    @Published var result = 0.0
    @Published var numbers = [Double]()
    @Published var signs = [String]()
    
    @Published var problemString = [String]()
    var problemStringLabel: String {
        var formatted = ""
        for character in problemString {
            switch character {
            case "+":
                formatted.append(" + ")
            case "-":
                formatted.append(" - ")
            case "x":
                formatted.append(" x ")
            case "÷":
                formatted.append(" ÷ ")
            case ".":
                formatted.append(".")
            case "=":
                formatted.append(" = ")
            default:
                formatted.append(Double(character)!.formatted())
            }
        }
        return formatted
    }
    
    // Canvas
    @Published var size: CGSize = .zero
    @Published var currentLine = Line()
    @Published var lines: [Line] = []
    
    // Will not run on Xcode Simulator - must use physical device
    func predict() -> String? {
        let tempLine = Binding(
            get: { self.currentLine },
            set: { self.currentLine = $0 }
        )
        let tempLines = Binding(
            get: { self.lines },
            set: { self.lines = $0 }
        )
        do {
            if let image = CanvasView(calculatorModel: CalculatorModel(), currentLine: tempLine, lines: tempLines).snapshot(targetSize: size).resize(to: CGSize(width: 299, height: 299)) {
                
                if let pixelBuffer = image.pixelBuffer() {
                    
                    let model = try CharacterClassifier(configuration: MLModelConfiguration())
                    let prediction = try model.prediction(image: pixelBuffer)
                    
                    currentLine.points.removeAll()
                    lines.removeAll()
                    
                    return prediction.classLabel
                }
            }
        } catch {
            alertTitle = error.localizedDescription
            showAlert = true
        }
        return nil
    }
    
    func solveProblem() {
        var currentNumberString = ""
        for character in problemString {
            if character == "+" || character == "-" || character == "x" || character == "÷" || character == "=" {
                signs.append(character)
                numbers.append(Double(currentNumberString)!)
                currentNumberString = ""
            }
            else {
                currentNumberString.append(character)
            }
        }
        
        result = numbers[0]
        for index in 0..<numbers.count {
            let sign = signs[index]
            
            if sign != "=" {
                let number = numbers[index + 1]

                switch sign {
                case "+":
                    result += number
                case "-":
                    result -= number
                case "x":
                    result *= number
                case "÷":
                    result /= number
                default:
                    fatalError()
                }
            }
        }
        
        numbers.removeAll()
        signs.removeAll()
        problemString.removeAll()
        
        alertTitle = result.formatted()
        showAlert = true
    }
}
