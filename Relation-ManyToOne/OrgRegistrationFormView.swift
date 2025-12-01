import SwiftUI
import SwiftData

struct RegistrationFormView: View {
  //  @Environment(\.modelContext) private var modelContext
  //  @Query(sort: \Person.name) private var people: [Person]

    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    AddPersonView()
                } label: {
                    Text("Add Person")
                }
                
                NavigationLink {
                    AddCarView()
                } label: {
                    Text("Add Car")
                }
              }
            .navigationTitle("Register Person or Car")
        }
    }
}

#Preview {
    RegistrationFormView()
        .modelContainer(for: [Person.self, CarModel.self], inMemory: true)
}

