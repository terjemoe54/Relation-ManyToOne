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

   
}

#Preview {
    ContentView()
}
