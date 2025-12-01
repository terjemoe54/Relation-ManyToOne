//
//  AddCarView.swift
//  Relation-ManyToOne
//
//  Created by Terje Moe on 01/12/2025.
//

import SwiftData
import SwiftUI

struct AddCarView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var owner: Int = 30

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
               
            }
            .navigationTitle("New Car")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { add() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func add() {
        let c = CarModel(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        context.insert(c)
        
        try? context.save()
        dismiss()
    }
}

#Preview {
    AddCarView()
}
