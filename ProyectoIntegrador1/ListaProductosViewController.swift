import UIKit
import FirebaseDatabase
import FirebaseStorage

class ListaProductosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buscador: UITextField!
    @IBOutlet weak var buscsrVoz: UIButton!
    
    var categoria: Categoria?
    var categoriaID: String?
    var productos: [Producto] = []
    var productosFiltrados: [Producto] = [] // Array para almacenar productos filtrados
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Asegúrate de que la categoría esté configurada antes de intentar cargar productos
        if let categoria = categoria {
            cargarProductos(categoriaID: categoria.id)
        } else {
            print("Error: No se ha proporcionado una categoría")
        }
        
        // Configura el delegado del buscador para actualizar la tabla mientras se escribe
        buscador.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    func cargarProductos(categoriaID: String) {
        ref.child("categorias").child(categoriaID).child("productos").observe(.value) { snapshot in
            var nuevosProductos: [Producto] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let productoData = snap.value as? [String: Any],
                   let nombre = productoData["nombre"] as? String,
                   let descripcion = productoData["descripcion"] as? String,
                   let precio = productoData["precio"] as? Double,
                   let stock = productoData["stock"] as? Int,
                   let imagenURL = productoData["imagenURL"] as? String {
                    
                    let producto = Producto(id: snap.key, nombre: nombre, descripcion: descripcion, precio: precio, stock: stock, imagenURL: imagenURL)
                    nuevosProductos.append(producto)
                }
            }
            
            self.productos = nuevosProductos
            self.productosFiltrados = nuevosProductos // Al cargar los productos, también actualizamos los filtrados
            self.tableView.reloadData()
        }
    }

    // Método para filtrar productos
    func filtrarProductos() {
        guard let textoBusqueda = buscador.text, !textoBusqueda.isEmpty else {
            productosFiltrados = productos // Si no hay texto en el campo de búsqueda, mostrar todos los productos
            tableView.reloadData()
            return
        }
        
        // Filtrar productos según el nombre
        productosFiltrados = productos.filter { producto in
            return producto.nombre.lowercased().contains(textoBusqueda.lowercased())
        }
        
        tableView.reloadData() // Actualizar la tabla con los productos filtrados
    }

    // Método para actualizar los productos mientras se escribe en el buscador
    @objc func textFieldDidChange() {
        filtrarProductos() // Filtrar cada vez que cambie el texto
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productosFiltrados.count // Usamos el array de productos filtrados
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductoCell", for: indexPath)
        let producto = productosFiltrados[indexPath.row] // Usamos el array filtrado
        
        cell.textLabel?.text = producto.nombre
        cell.detailTextLabel?.text = "Precio: \(producto.precio), Stock: \(producto.stock)"
        
        let storageRef = Storage.storage().reference(forURL: producto.imagenURL)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error al cargar imagen: \(error)")
            } else if let data = data {
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data)
                    cell.setNeedsLayout()
                }
            }
        }
        
        return cell
    }

    // Habilitar el estilo de edición para eliminar productos
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete // Esto habilita el botón de borrar
    }

    // Acción para eliminar un producto
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Mostrar alerta de confirmación
            let producto = productosFiltrados[indexPath.row]
            let alertController = UIAlertController(title: "Eliminar Producto", message: "¿Estás seguro de que deseas eliminar el producto?", preferredStyle: .alert)
            
            // Acción para eliminar el producto
            let deleteAction = UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
                self?.eliminarProducto(producto: producto)
            }
            alertController.addAction(deleteAction)
            
            // Acción para cancelar
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            // Mostrar la alerta
            present(alertController, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let productoSeleccionado = productosFiltrados[indexPath.row]
        performSegue(withIdentifier: "editarProductoSegue", sender: productoSeleccionado)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Función para eliminar un producto de Firebase
    func eliminarProducto(producto: Producto) {
        ref.child("categorias").child(categoria?.id ?? "").child("productos").child(producto.id).removeValue { error, _ in
            if let error = error {
                print("Error al eliminar el producto: \(error.localizedDescription)")
            } else {
                // Actualizar la lista de productos después de eliminarlo
                if let index = self.productosFiltrados.firstIndex(where: { $0.id == producto.id }) {
                    self.productosFiltrados.remove(at: index)
                    self.productos.remove(at: index)
                    self.tableView.reloadData()
                }
            }
        }
    }

    @IBAction func AgregarProducto(_ sender: Any) {
        // Verifica si 'categoria' está configurada
        if let categoria = categoria {
            performSegue(withIdentifier: "agregarProductoSegue", sender: categoria)
        } else {
            print("Error: No se ha seleccionado una categoría.")
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "agregarProductoSegue" {
            if let destinoVC = segue.destination as? AgregarProductosViewController {
                var categoriaSeleccionada = sender as? Categoria
                destinoVC.categoria = categoriaSeleccionada
                
            }
        } else if segue.identifier == "editarProductoSegue" {
            if let destinoVC = segue.destination as? EditarProductoViewController,
               var productoSeleccionado = sender as? Producto {
                // Pasa el producto al controlador de edición
                destinoVC.producto = productoSeleccionado
                var categoriaSeleccionada = sender as? Categoria
                destinoVC.categoria = categoriaSeleccionada
            }
        }
    }
}
