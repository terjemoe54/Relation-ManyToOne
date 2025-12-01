//
//  AddPersonView.swift
//  Relation-ManyToOne
//
//  Created by Terje Moe on 01/12/2025.
//
import SwiftData
import SwiftUI

struct AddPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var name: String = ""
    @State private var age: Int = 30

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                Stepper(value: $age, in: 1...120) {
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(age)")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Person")
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
        let p = Person(name: name.trimmingCharacters(in: .whitespacesAndNewlines), age: age)
        context.insert(p)
        try? context.save()
        dismiss()
    }
}
