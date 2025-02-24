//
//  InstructionsView.swift
//  MealPro
//
//  Created by Madhu Babu Adiki on 2/23/25.
//

import SwiftUI

struct InstructionsView: View {
    let instructions: [AnalyzedInstruction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Instructions")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(instructions, id: \.name) { instruction in
                VStack(alignment: .leading, spacing: 5) {
                    if let instructionName = instruction.name, !instructionName.isEmpty {
                        Text(instructionName)
                            .font(.subheadline)
                            .padding(.horizontal)
                    }
                    
                    if let steps = instruction.steps?.compactMap({ $0 }), !steps.isEmpty {
                        ForEach(steps, id: \.number) { step in
                            Text("Step \(step.number): \(step.step)")
                                .font(.caption)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    InstructionsView(instructions: [
        AnalyzedInstruction(name: "", steps: [
            InstructionStep(number: 1, step: "Boil water"),
            InstructionStep(number: 2, step: "add spinach")
        ])
    ])
}
