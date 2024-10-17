import UIKit

// Clase principal del ViewController que maneja la tabla y la carga de datos de personas con paginación
class ViewController: UIViewController {

    var tableView: UITableView!   // La tabla que mostrará la lista de personas
    var people: [Person] = []     // Arreglo que contendrá las personas descargadas
    var isLoading = false         // Flag para evitar solicitudes duplicadas mientras se cargan datos
    var currentPage = 1           // La página actual que se está descargando
    let itemsPerPage = 9          // Número de resultados por página (definido en la API)

    // Método llamado cuando la vista se carga por primera vez
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Paginación de Personas"     // Título del ViewController
        view.backgroundColor = .white        // Fondo blanco para la vista

        // Inicialización de la tabla con el mismo tamaño de la vista principal
        tableView = UITableView(frame: view.bounds)
        
        // Registro de la celda personalizada `PersonTableViewCell` para reutilización
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        
        // Establece el delegado y el datasource para la tabla
        tableView.delegate = self
        tableView.dataSource = self
        
        // Agrega la tabla a la vista principal
        view.addSubview(tableView)

        // Cargar los datos iniciales de la primera página
        loadPeople(page: currentPage)
    }

    // Función para cargar más personas desde la API
    func loadPeople(page: Int) {
        // Si ya se está cargando, no se inicia otra solicitud
        guard !isLoading else { return }

        isLoading = true  // Marca que estamos en proceso de carga

        // Construye la URL de la API con la página y el número de resultados por página
        let urlString = "https://randomuser.me/api/?page=\(page)&results=\(itemsPerPage)"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            isLoading = false  // Si la URL no es válida, libera el flag de carga
            return
        }

        // Realiza la solicitud de datos a la API
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.isLoading = false }  // Al finalizar, sea éxito o error, libera el flag de carga

            // Verifica si ocurrió un error
            if let error = error {
                print("Error en la solicitud: \(error.localizedDescription)")
                return
            }

            // Verifica si se recibieron datos
            guard let data = data else {
                print("No se recibieron datos")
                return
            }

            // Intenta decodificar los datos recibidos en un objeto `Results` (que contiene personas)
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Results.self, from: data)
                let newPeople = result.results  // Lista de nuevas personas descargadas

                // Actualiza la UI en el hilo principal
                DispatchQueue.main.async {
                    self.people.append(contentsOf: newPeople)  // Agrega las nuevas personas al arreglo
                    self.tableView.reloadData()                // Recarga la tabla para mostrar los nuevos datos
                }
            } catch {
                print("Error al decodificar JSON: \(error)")
            }
        }

        task.resume()  // Inicia la solicitud
    }
}

// Extensiones para conformar a los protocolos de UITableView (manejan los datos y la interacción con la tabla)
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableView DataSource

    // Número de filas en la sección (corresponde al número de personas en la lista)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    // Configuración de cada celda individual
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Reutiliza una celda de tipo `PersonTableViewCell` o crea una nueva si no hay disponible
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as? PersonTableViewCell else {
            return UITableViewCell()  // En caso de error, devuelve una celda vacía
        }

        // Obtiene la persona correspondiente a la fila actual
        let person = people[indexPath.row]
        
        // Configura la celda con los datos de la persona
        cell.configure(with: person)

        return cell
    }

    //UITableView Delegate

    // Este método se llama cuando una celda está a punto de ser mostrada
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Si la celda que está a punto de mostrarse es la última (de la lista actual)
        if indexPath.row == people.count - 1 {
            // Incrementa el número de página y carga más personas
            currentPage += 1
            loadPeople(page: currentPage)
        }
    }
}
