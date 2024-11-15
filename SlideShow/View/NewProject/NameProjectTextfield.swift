//
//  MyTextField.swift
//  SlideShow
//
//  Created by Jonathan Nunez on 6/12/24.
//

import SwiftUI

struct NameProjectTextfield: UIViewRepresentable {
    typealias UIViewType = UITextField

    @Binding var projectName: String
    @Binding var becomeFirstResponder: Bool
    var textField: UITextField!
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NameProjectTextfield
        
        init(_ parent: NameProjectTextfield) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            parent.projectName = textField.text ?? ""
            return true
        }
    }
    
    func makeCoordinator() -> NameProjectTextfield.Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 32, weight: .bold)
        tf.textColor = .white
        tf.textAlignment = .center
        tf.text = projectName
        
        tf.delegate = context.coordinator
        return tf
    }
    
    func updateUIView(_ textField: UITextField, context: Context) {
        if self.becomeFirstResponder {
            DispatchQueue.main.async {
                textField.becomeFirstResponder()
                self.becomeFirstResponder = false
            }
        }
    }
}
