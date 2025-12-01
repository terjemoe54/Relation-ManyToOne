import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Person.name, order: .forward)]) private var people: [Person]

    @State private var showingAddPerson = false

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    ContentUnavailableView("No People", systemImage: "person.2", description: Text("Tap + to add some."))
                } else {
                    List {
                        ForEach(people) { person in
                            NavigationLink(value: person) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(person.name)
                                            .font(.headline)
                                        Spacer()
                                        Text("Age \(person.age)")
                                            .foregroundStyle(.secondary)
                                    }
                                    Text(summary(for: person))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                    if !person.cars.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 8) {
                                                ForEach(person.cars) { car in
                                                    Label(car.name, systemImage: "car")
                                                        .padding(.horizontal, 8)
                                                        .padding(.vertical, 4)
                                                        .background(.thinMaterial, in: Capsule())
                                                }
                                            }
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                            }
                            .contextMenu {
                                Button(role: .destructive) { delete(person) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("People")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Seed") { seedSampleData() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddPerson = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Person")
                }
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailView(person: person)
            }
            .sheet(isPresented: $showingAddPerson) {
                AddPersonView()
                    .presentationDetents([.medium])
            }
        }
    }

    private func summary(for person: Person) -> String {
        let count = person.cars.count
        switch count {
        case 0: return "No cars"
        case 1: return "1 car"
        default: return "\(count) cars"
        }
    }

    private func delete(_ offsets: IndexSet) {
        for index in offsets { context.delete(people[index]) }
        try? context.save()
    }

    private func delete(_ person: Person) {
        context.delete(person)
        try? context.save()
    }

    private func seedSampleData() {
        // Only seed if empty to avoid duplicates
        guard people.isEmpty else { return }
        let alice = Person(name: "Alice", age: 30)
        let bob = Person(name: "Bob", age: 42)
        let c1 = CarModel(name: "Civic", owner: alice)
        let c2 = CarModel(name: "Model 3", owner: alice)
        let c3 = CarModel(name: "Corolla", owner: bob)
        context.insert(alice)
        context.insert(bob)
        context.insert(c1)
        context.insert(c2)
        context.insert(c3)
        try? context.save()
    }
}

private struct AddPersonView: View {
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, CarModel.self, configurations: config)
    let context = container.mainContext

    let alice = Person(name: "Preview Alice", age: 29)
    let car = CarModel(name: "Preview Car", owner: alice)
    context.insert(alice)
    context.insert(car)

    return ContentView()
        .modelContainer(container)
}
