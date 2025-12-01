//
//  PersonDetailView.swift
//  Relation-ManyToOne
//
//  Created by Terje Moe on 01/12/2025.
//
import SwiftUI
import SwiftData

struct PersonDetailView: View {
    @Environment(\.modelContext) private var context
    @State var person: Person

    @Query(sort: [SortDescriptor(\CarModel.name, order: .forward)]) private var cars: [CarModel]
    @State private var newCarName: String = ""

    var body: some View {
        Form {
            Section("Info") {
                TextField("Name", text: Binding(
                    get: { person.name },
                    set: { person.name = $0 }
                ))
                Stepper(value: Binding(
                    get: { person.age },
                    set: { person.age = $0 }
                ), in: 1...120) {
                    HStack {
                        Text("Age")
                        Spacer()
                        Text("\(person.age)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Cars") {
                if person.cars.isEmpty {
                    Text("No cars yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(person.cars) { car in
                        HStack {
                            Text(car.name)
                            Spacer()
                            Button(role: .destructive) {
                                context.delete(car)
                                try? context.save()
                            } label: {
                                Image(systemName: "trash")
                            }
                        }
                    }
                }
                HStack {
                    TextField("New car name", text: $newCarName)
                    Button("Add") { addCar() }
                        .disabled(newCarName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { try? context.save() }
    }

    private func addCar() {
        let name = newCarName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let car = CarModel(name: name, owner: person)
        context.insert(car)
        newCarName = ""
        try? context.save()
    }
}
