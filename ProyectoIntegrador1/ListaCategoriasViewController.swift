import UIKit
import FirebaseDatabase

class ListaCategoriasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!  // Aquí conectamos el TableView

    // MARK: - Variables
    var ref: DatabaseReference!
    var categorias: [Categoria] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configurar la referencia a Firebase
        ref = Database.database().reference()

        // Configuración del TableView
        tableView.dataSource = self
        tableView.delegate = self

        // Obtener las categorías desde Firebase
        obtenerCategorias()
    }

    // MARK: - Función para Obtener Categorías desde Firebase
    func obtenerCategorias() {
        ref.child("categorias").observe(.value, with: { snapshot in
            var nuevasCategorias: [Categoria] = []
            
            // Iterar a través de cada categoría en el snapshot
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let categoria = Categoria(snapshot: snapshot) {
                    nuevasCategorias.append(categoria)
                }
            }

            // Asignar las categorías obtenidas y recargar la tabla
            self.categorias = nuevasCategorias
            self.tableView.reloadData()  // Recargar la tabla para mostrar las categorías
        })
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Crear o reutilizar la celda
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriaCell", for: indexPath)
        
        // Obtener la categoría correspondiente
        let categoria = categorias[indexPath.row]
        
        // Configurar la celda con el nombre de la categoría
        cell.textLabel?.text = categoria.nombre
        cell.detailTextLabel?.text = categoria.descripcion
        
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Acción al seleccionar una categoría (opcional)
        let categoria = categorias[indexPath.row]
        print("Categoría seleccionada: \(categoria.nombre)")

        // Realizar el segue a ListaProductosViewController
        performSegue(withIdentifier: "showProductos", sender: categoria)
    }

    // MARK: - Preparar datos para el segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductos" {
            if let destinoVC = segue.destination as? ListaProductosViewController {
                // Puedes pasar la categoría seleccionada a ListaProductosViewController
                if let categoriaSeleccionada = sender as? Categoria {
                    destinoVC.categoria = categoriaSeleccionada
                }
            }
        }
    }
}
