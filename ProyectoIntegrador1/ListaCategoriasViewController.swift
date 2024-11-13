import UIKit
import FirebaseDatabase

class ListaCategoriasViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var categorias: [Categoria] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        tableView.dataSource = self
        tableView.delegate = self
        
        obtenerCategorias()
    }

    func obtenerCategorias() {
        ref.child("categorias").observe(.value, with: { snapshot in
            var nuevasCategorias: [Categoria] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let categoria = Categoria(snapshot: snapshot) {
                    nuevasCategorias.append(categoria)
                }
            }
            
            self.categorias = nuevasCategorias
            self.tableView.reloadData()
        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorias.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriaCell", for: indexPath)
        let categoria = categorias[indexPath.row]
        cell.textLabel?.text = categoria.nombre
        cell.detailTextLabel?.text = categoria.descripcion
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let categoria = categorias[indexPath.row]
        print("Categoría seleccionada: \(categoria.nombre)")
        
        performSegue(withIdentifier: "showProductos", sender: categoria)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductos" {
            if let destinoVC = segue.destination as? ListaProductosViewController,
               let categoriaSeleccionada = sender as? Categoria {
                destinoVC.categoria = categoriaSeleccionada
            }
        }
    }
}
