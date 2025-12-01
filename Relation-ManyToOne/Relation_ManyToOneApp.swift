//
//  Relation_ManyToOneApp.swift
//  Relation-ManyToOne
//
//  Created by Terje Moe on 30/11/2025.
//

import SwiftUI
import SwiftData

@main
struct Relation_ManyToOneApp: App {
    var body: some Scene {
        WindowGroup {
           // RegistrationFormView()
            ContentView()
                .modelContainer(for: [Person.self])
        }
    }
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
