//
//  File.swift
//  Relation-ManyToOne
//
//  Created by Terje Moe on 30/11/2025.
//
import SwiftData

@Model
class Person {
    var name: String
    var age: Int

    @Relationship(inverse: \CarModel.owner)
    var cars: [CarModel] = []

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

@Model
class CarModel {
    var name: String
    var owner: Person?   // optional: cars may be unassigned

    init(name: String, owner: Person? = nil) {
        self.name = name
        self.owner = owner
    }
}
