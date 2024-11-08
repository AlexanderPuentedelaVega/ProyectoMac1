import UIKit
import FirebaseDatabase
import FirebaseStorage

class AgregarProductosViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var nombreProductoTextField: UITextField!
    @IBOutlet weak var descripcionProductoTextField: UITextField!
    @IBOutlet weak var precioProductoTextField: UITextField!
    @IBOutlet weak var stockProductoTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!  // ImageView para mostrar la imagen seleccionada
    @IBOutlet weak var registrarProductoButton: UIButton!
    @IBOutlet weak var agregarImagenButton: UIButton!  // Botón para seleccionar imagen

    // MARK: - Variables
    var ref: DatabaseReference!
    var categoria: Categoria?
    var selectedImage: UIImage? // Imagen seleccionada por el usuario

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        registrarProductoButton.layer.cornerRadius = 10
        agregarImagenButton.layer.cornerRadius = 10
    }

    // MARK: - Acción para seleccionar imagen
    @IBAction func agregarImagen(_ sender: UIButton) {
        // Crear un UIImagePickerController para seleccionar la imagen
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            self.selectedImage = image
            self.imageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - Acción del botón para registrar producto
    @IBAction func registrarProducto(_ sender: UIButton) {
        guard let nombre = nombreProductoTextField.text, !nombre.isEmpty,
              let descripcion = descripcionProductoTextField.text, !descripcion.isEmpty,
              let precioStr = precioProductoTextField.text, let precio = Double(precioStr),
              let stockStr = stockProductoTextField.text, let stock = Int(stockStr) else {
            showAlert(message: "Por favor complete todos los campos.")
            return
        }

        // Subir la imagen a Firebase Storage
        if let image = selectedImage {
            uploadImageToFirebaseStorage(image) { [weak self] imageURL in
                guard let self = self else { return }

                // Crear un producto con los datos
                let producto = [
                    "nombre": nombre,
                    "descripcion": descripcion,
                    "precio": precio,
                    "stock": stock,
                    "imagenURL": imageURL,  // Usamos la URL de la imagen subida
                    "categoriaID": self.categoria?.id ?? ""
                ] as [String: Any]

                // Guardar el producto en Firebase
                if let categoriaID = self.categoria?.id {
                    let productoRef = self.ref.child("categorias").child(categoriaID).child("productos").childByAutoId()
                    productoRef.setValue(producto) { error, _ in
                        if let error = error {
                            self.showAlert(message: "Error al registrar el producto: \(error.localizedDescription)")
                        } else {
                            self.showAlert(message: "Producto registrado exitosamente!")
                            self.limpiarCampos()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Subir imagen a Firebase Storage
    func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("productos").child(UUID().uuidString + ".jpg")
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error al subir la imagen: \(error.localizedDescription)")  // Agregar depuración
                    self.showAlert(message: "Error al subir la imagen: \(error.localizedDescription)")
                    return
                }
                
                // Si la imagen se sube correctamente, intentamos obtener la URL de descarga
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error al obtener la URL de la imagen: \(error.localizedDescription)")  // Depuración adicional
                        self.showAlert(message: "Error al obtener la URL de la imagen: \(error.localizedDescription)")
                    } else if let imageURL = url?.absoluteString {
                        print("URL de la imagen subida: \(imageURL)")  // Verificar la URL obtenida
                        completion(imageURL)
                    }
                }
            }
        }
    }


    // MARK: - Función para mostrar alerta
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Limpiar los campos de texto
    func limpiarCampos() {
        nombreProductoTextField.text = ""
        descripcionProductoTextField.text = ""
        precioProductoTextField.text = ""
        stockProductoTextField.text = ""
        imageView.image = nil
        selectedImage = nil
    }
}
