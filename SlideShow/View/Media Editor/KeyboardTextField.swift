//
//  KeyboiardFieldView.swift
//  SlideShow
//
//  Created by Shahrukh on 13/06/2024.
//

import SwiftUI
import UIKit

struct KeyboardTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    var placeholder: String // Add a placeholder property

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.alpha = 0.0
        textField.returnKeyType = .done // Set the return key type to "Done"
        textField.placeholder = placeholder // Set the placeholder text
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.placeholder = placeholder // Update the placeholder text
        if isEditing {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, isEditing: $isEditing)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool

        init(text: Binding<String>, isEditing: Binding<Bool>) {
            _text = text
            _isEditing = isEditing
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.text = textField.text ?? ""
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            isEditing = false
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard when the return key is pressed
            return true
        }
    }
}

