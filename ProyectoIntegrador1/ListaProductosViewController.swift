//
//  ListaProductosViewController.swift
//  ProyectoIntegrador1
//
//  Created by Alexander Puente de la Vega on 8/11/24.
//

import UIKit

class ListaProductosViewController: UIViewController {
    var categoria: Categoria?

    @IBOutlet weak var Buscador: UITextField!
    
    @IBOutlet weak var BuscsrVoz: UIButton!
    @IBAction func BotonBuscar(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let categoria = categoria {
                    print("Categoría seleccionada en ListaProductosViewController: \(categoria.nombre)")
                }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
