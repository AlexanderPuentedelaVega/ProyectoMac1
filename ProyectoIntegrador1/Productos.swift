//
//  Productos.swift
//  ProyectoIntegrador1
//
//  Created by Alexander Puente de la Vega on 8/11/24.
//

import Foundation

import FirebaseDatabase

// Modelo de Categoria
struct Categoria {
    let id: String
    let nombre: String
    let descripcion: String
    let productos: [Producto]  // Productos asociados a la categoría
    
    // Inicializador para crear una categoria desde un snapshot de Firebase
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any],
              let nombre = value["nombre"] as? String,
              let descripcion = value["descripcion"] as? String else {
            return nil
        }
        
        // Asignar los valores desde el snapshot
        self.id = snapshot.key  // Usamos el key del snapshot como ID de la categoría
        self.nombre = nombre
        self.descripcion = descripcion
        self.productos = []  // Asignamos un array vacío para los productos (puedes cargar los productos más tarde si es necesario)
    }
}

// Modelo de Producto
struct Producto {
    let id: String
    let nombre: String
    let descripcion: String
    let precio: Double
    let stock: Int
    let imagenURL: String
}
