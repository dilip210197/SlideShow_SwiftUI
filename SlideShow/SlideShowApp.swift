//
//  SlideShowApp.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import SwiftUI
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    static private(set) var shared: AppDelegate! = nil
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppDelegate.shared = self
        downloadCategory()
        downloadPlaylist()
        registerApplicationsDefaults()
        return true
    }
    
    private func registerApplicationsDefaults() {
        UserDefaults.standard.register(defaults: [Keys.showOnBoarding: true])
    }
    
    func downloadPlaylist() {
        let url = URL(string: "http://157.230.235.143/api/playlist.php")!
        var request = URLRequest(url: url)
        request.setValue("text/html", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: "playlist_data")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }

    func downloadCategory() {
        let url = URL(string: "http://157.230.235.143/api/categories.php")!
        var request = URLRequest(url: url)
        request.setValue("text/html", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .fragmentsAllowed)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    UserDefaults.standard.set(jsonString, forKey: "category_data")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
}

@main
struct SlideShowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.colorScheme) var colorScheme
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([ Item.self, Project.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ProjectsView()
                .environmentObject(SubscriptionsViewModel())
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
