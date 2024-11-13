import UIKit
import Firebase

class EditarProductoViewController: UIViewController {

    var producto: Producto?  // Producto que se pasará desde el otro ViewController
    var categoria: Categoria? // Definimos la variable para la categoría seleccionada

    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var precioTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(categoria?.id)
        if let producto = producto {
            nombreTextField.text = producto.nombre
            descripcionTextField.text = producto.descripcion
            precioTextField.text = "\(producto.precio)"
            stockTextField.text = "\(producto.stock)"
        } else {
            print("El producto no se ha recibido correctamente.")
        }

        if let categoria = categoria {
            print("Categoría ID: \(categoria.id)")  // Asegúrate de ver el ID de la categoría
        }
    }

    // Acción para guardar cambios
    @IBAction func guardarCambios(_ sender: Any) {
        guard let nombre = nombreTextField.text, !nombre.isEmpty,
              let descripcion = descripcionTextField.text, !descripcion.isEmpty,
              let precioStr = precioTextField.text, let precio = Double(precioStr),
              let stockStr = stockTextField.text, let stock = Int(stockStr),
              let producto = producto,
              let categoriaID = categoria?.id else {
            
            print("Error: Datos faltantes o categoría no seleccionada")
            return
        }

        let ref = Database.database().reference()
        ref.child("categorias")
            .child(categoriaID)  // Usamos el ID de la categoría
            .child("productos")
            .child(producto.id)
            .updateChildValues([
                "nombre": nombre,
                "descripcion": descripcion,
                "precio": precio,
                "stock": stock
            ]) { (error, _) in
                if let error = error {
                    print("Error al actualizar producto: \(error.localizedDescription)")
                } else {
                    print("Producto actualizado con éxito")
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }

}

