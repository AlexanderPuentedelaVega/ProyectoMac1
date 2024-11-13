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
    var categoria: Categoria? // Definimos la variab    le para la categoría seleccionada
    var selectedImage: UIImage? // Imagen seleccionada por el usuario

    override func viewDidLoad() {
        super.viewDidLoad()
        print(categoria?.id)
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

                // Si no se ha seleccionado una categoría, mostramos un mensaje de error
                guard let categoriaID = self.categoria?.id else {
                    self.showAlert(message: "No se ha seleccionado una categoría.")
                    return
                }

                // Crear un producto con los datos
                let producto = [
                    "nombre": nombre,
                    "descripcion": descripcion,
                    "precio": precio,
                    "stock": stock,
                    "imagenURL": imageURL
                ] as [String : Any]
                
                // Agregar el producto a la categoría seleccionada en Firebase
                self.ref.child("categorias").child(categoriaID).child("productos").childByAutoId().setValue(producto) { error, _ in
                    if let error = error {
                        self.showAlert(message: "Error al registrar el producto: \(error.localizedDescription)")
                    } else {
                        self.showAlert(message: "Producto registrado exitosamente.")
                    }
                }
            }
        }
    }

    // MARK: - Subir imagen a Firebase Storage
    func uploadImageToFirebaseStorage(_ image: UIImage, completion: @escaping (String) -> Void) {
        let storageRef = Storage.storage().reference().child("productos").child(UUID().uuidString + ".jpg")
        if let imageData = image.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error al subir imagen: \(error.localizedDescription)")
                    return
                }

                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error al obtener la URL de descarga: \(error.localizedDescription)")
                        return
                    }

                    if let imageURL = url?.absoluteString {
                        completion(imageURL)
                    }
                }
            }
        }
    }

    // MARK: - Mostrar alerta
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Información", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}
