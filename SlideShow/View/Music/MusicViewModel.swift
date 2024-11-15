//
//  MusicViewModel.swift
//  SlideShow
//
//  Created by Shahrukh on 19/06/2024.
//

import Foundation
import Combine

// Define the MusicCategory struct
class MusicCategory: Identifiable, Codable {
    let iD : Int?
    let name : String?
    let type : String?
    let cover : String?

    enum CodingKeys: String, CodingKey {

        case iD = "ID"
        case name = "Name"
        case type = "Type"
        case cover = "Cover"
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        iD = try values.decodeIfPresent(Int.self, forKey: .iD)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        cover = try values.decodeIfPresent(String.self, forKey: .cover)
    }

}

struct Music : Codable, Identifiable {
    var id = UUID()
    
    let type : String?
    let category : String?
    var songs : [Song]?

    enum CodingKeys: String, CodingKey {

        case type = "Type"
        case category = "Category"
        case songs = "Songs"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        songs = try values.decodeIfPresent([Song].self, forKey: .songs)
    }

}

struct Song : Codable, Identifiable {
    var id : Int = 0
    var name : String?
    let file : String?
    let duration : String?

    enum CodingKeys: String, CodingKey {

        case id = "ID"
        case name = "Name"
        case file = "File"
        case duration = "Duration"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
       id = try values.decodeIfPresent(Int.self, forKey: .id) ?? -1
        name = try values.decodeIfPresent(String.self, forKey: .name)
        file = try values.decodeIfPresent(String.self, forKey: .file)
        duration = try values.decodeIfPresent(String.self, forKey: .duration)
    }

}

// ViewModel to manage fetching and storing categories
class MusicCategoryViewModel: ObservableObject {
    @Published var categories: [MusicCategory] = []
    @Published var selectedCategory: MusicCategory?
    @Published var songs: [Song] = []

    init() {
        fetchCategories()
    }
    
    func fetchMusic() {
     let category = UserDefaults.standard.string(forKey: "playlist_data")
        if let data = category?.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                let music = try decoder.decode([Music].self, from: data)
                self.songs = music.filter { item in
                    if item.category == selectedCategory?.name {
                        return true
                    }
                    return false
                }.first?.songs ?? []
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
    }

    func fetchCategories() {
     let category = UserDefaults.standard.string(forKey: "category_data")
        if let data = category?.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                let music = try decoder.decode([MusicCategory].self, from: data)
                self.categories = music.filter { item in
                    if item.type == "Music" {
                        return true
                    }
                    return false
                }
                print(self.categories)
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
    }
    
    func selectCategory(_ category: MusicCategory) {
        self.selectedCategory = category
        fetchMusic()
    }
    
}
