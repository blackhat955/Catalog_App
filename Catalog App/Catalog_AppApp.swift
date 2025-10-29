//
//  Catalog_AppApp.swift
//  Catalog App
//
//  Created by DURGESH TIWARI on 10/29/25.
//

import SwiftUI
import CoreData

@main
struct Catalog_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
