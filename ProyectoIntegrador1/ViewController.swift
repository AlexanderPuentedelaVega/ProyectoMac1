import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController {

    // Outlets para los campos de texto de email y contraseña
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Outlet para la vista que actuará como botón de Google Sign-In
    @IBOutlet weak var googleSignInView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configuración inicial de Firebase y del botón de Google Sign-In
        FirebaseApp.configure()
        setupGoogleSignInButton()
    }
    
    // Configuración de la vista como botón de Google Sign-In
    private func setupGoogleSignInButton() {
        googleSignInView.layer.cornerRadius = 8
        googleSignInView.backgroundColor = UIColor.systemBlue
        googleSignInView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(googleSignInTapped))
        googleSignInView.addGestureRecognizer(tapGesture)
    }

    // Acción de inicio de sesión con correo y contraseña
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            if let error = error {
                print("Error al iniciar sesión con email: \(error.localizedDescription)")
                return
            }
            
            print("Inicio de sesión exitoso con email.")
            
            // Obtener el rol del usuario desde Realtime Database
            guard let userId = authResult?.user.uid else { return }
            Database.database().reference().child("usuarios").child(userId).observeSingleEvent(of: .value) { snapshot in
                if let userData = snapshot.value as? [String: Any],
                   let role = userData["role"] as? String {
                    
                    if role == "Administrador" {
                        print("Inicio de sesión exitoso como Administrador.")
                    } else {
                        print("Inicio de sesión exitoso como Empleado.")
                    }
                    
                    // Redirigir a otra vista según el rol
                    self?.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                } else {
                    print("Rol no encontrado.")
                }
            }
        }
    }

    // Método para iniciar sesión con Google
    @objc func googleSignInTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Error en el inicio de sesión con Google: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error al autenticar con Firebase: \(error.localizedDescription)")
                    return
                }
                
                guard let user = authResult?.user else { return }
                let userId = user.uid
                
                // Obtener el rol del usuario desde Realtime Database
                Database.database().reference().child("usuarios").child(userId).observeSingleEvent(of: .value) { snapshot in
                    if let userData = snapshot.value as? [String: Any],
                       let role = userData["role"] as? String {
                        
                        if role == "Administrador" {
                            print("Inicio de sesión exitoso como Administrador.")
                        } else {
                            print("Inicio de sesión exitoso como Empleado.")
                        }
                        
                        self?.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                    } else {
                        print("Rol no encontrado.")
                    }
                }
            }
        }
    }
}
