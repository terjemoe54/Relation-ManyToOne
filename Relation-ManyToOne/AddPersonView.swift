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
    @Query private var cars: [CarModel]
    @State private var selectedCar: CarModel?
    @State private var name: String = ""
    @State private var age: Int = 30
    @State private var car: CarModel?

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
                Picker("Car", selection: $selectedCar) {
                    Text("None").tag(Optional<CarModel>.none)
                    ForEach(cars, id: \.self) { car in
                        Text(car.name) // Change to the appropriate display property if needed
                            .tag(Optional(car))
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

#Preview {
    AddPersonView()
}
