//
//  AgregarCategoriaViewController.swift
//  ProyectoIntegrador1
//
//  Created by Alexander Puente de la Vega on 8/11/24.
//

import UIKit
import FirebaseDatabase


class AgregarCategoriaViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var descripcionTextField: UITextField!
    
    // Referencia a Firebase Database
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar la referencia a la base de datos
        ref = Database.database().reference()
    }
    
    // MARK: - IBActions
    @IBAction func registrarCategoria(_ sender: UIButton) {
        guardarCategoriaEnFirebase()
    }
    
    // MARK: - Función para Guardar en Firebase
    func guardarCategoriaEnFirebase() {
        guard let nombre = nombreTextField.text, !nombre.isEmpty,
              let descripcion = descripcionTextField.text, !descripcion.isEmpty else {
            mostrarAlerta(titulo: "Error", mensaje: "Por favor, complete todos los campos.")
            return
        }
        
        // Crear una nueva referencia para la categoría
        let categoriaRef = ref.child("categorias").childByAutoId()
        
        // Datos de la categoría
        let categoriaData: [String: Any] = [
            "nombre": nombre,
            "descripcion": descripcion
        ]
        
        // Guardar los datos en Firebase
        categoriaRef.setValue(categoriaData) { (error, _) in
            if let error = error {
                self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo guardar la categoría: \(error.localizedDescription)")
            } else {
                self.mostrarAlerta(titulo: "Éxito", mensaje: "La categoría se ha registrado correctamente.")
                self.limpiarCampos()
            }
        }
    }
    
    // MARK: - Función para Limpiar Campos
    func limpiarCampos() {
        nombreTextField.text = ""
        descripcionTextField.text = ""
    }
    
    // MARK: - Función para Mostrar Alerta
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }
}

