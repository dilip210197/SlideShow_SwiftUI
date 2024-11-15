//
//  Constant.swift
//  SlideShow
//
//  Created by Anuj Joshi on 14/06/24.
//

import UIKit

struct K {
    struct Path {
        static var DocumentURL: URL {
            return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        }
        
        static var LibraryURL: URL {
            return try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        }
        
        static var MovURL: URL {
            return LibraryURL.appendingPathComponent("Mov", isDirectory: true)
        }
    }
}
