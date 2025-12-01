import SwiftUI
import SwiftData

struct RegistrationFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Person.name) private var people: [Person]

    @State private var personName: String = ""
    @State private var personAge: String = ""
    @State private var carNames: [String] = [""]

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Name", text: $personName)
                        .autocorrectionDisabled(true)
                    if personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Name is required")
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    TextField("Age", text: $personAge)
                        .keyboardType(.numberPad)
                        .onChange(of: personAge) { newValue in
                            let filtered = newValue.filter { $0.isWholeNumber }
                            if filtered != newValue {
                                personAge = filtered
                            }
                        }
                    if Int(personAge) == nil || personAge.isEmpty {
                        Text("Valid age is required")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }

                Section("Cars (optional)") {
                    ForEach(carNames.indices, id: \.self) { index in
                        HStack {
                            TextField("Car name", text: $carNames[index])
                            if carNames.count > 1 {
                                Button(role: .destructive) {
                                    carNames.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    Button {
                        carNames.append("")
                    } label: {
                        Label("Add Car", systemImage: "plus.circle.fill")
                    }
                }

                Section {
                    Button("Save") {
                        savePerson()
                    }
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Register Person")
        }
    }

    private var canSave: Bool {
        !personName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Int(personAge) != nil
    }

    private func savePerson() {
        guard let age = Int(personAge), canSave else { return }
        let newPerson = Person(name: personName.trimmingCharacters(in: .whitespacesAndNewlines), age: age)

        for carName in carNames.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !carName.isEmpty {
            let car = CarModel(name: carName, owner: newPerson)
            modelContext.insert(car)
        }

        modelContext.insert(newPerson)

        do {
            try modelContext.save()
            clearForm()
        } catch {
            // Handle error appropriately in a real app
        }
    }

    private func clearForm() {
        personName = ""
        personAge = ""
        carNames = [""]
    }
}

#Preview {
    RegistrationFormView()
        .modelContainer(for: [Person.self, CarModel.self], inMemory: true)
}
