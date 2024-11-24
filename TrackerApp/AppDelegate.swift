//
//  AppDelegate.swift
//  Tracker
//
//  Created by Ilya Kalin on 22.08.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var trackerCategoryStore: TrackerCategoryStore = {
        let context = self.persistentContainer.viewContext
        return TrackerCategoryStore(context: context)
    }()
    
    lazy var trackerRecordStore: TrackerRecordStore = {
        let context = self.persistentContainer.viewContext
        return TrackerRecordStore(context: context)
    }()

    lazy var trackerStore: TrackerStore = {
        let context = self.persistentContainer.viewContext
        return TrackerStore(context: context)
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
      
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as? NSError {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }


}

