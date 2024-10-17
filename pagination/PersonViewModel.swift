import Foundation
import Combine

// Clase ViewModel que maneja la lógica de negocio y la comunicación con la API
class PersonViewModel: ObservableObject {
    // Propiedad observable que contiene la lista de personas, se actualizará la UI cuando cambie
    @Published var people: [Person] = []
    // Propiedad observable que indica si los datos se están cargando
    @Published var isLoading = false

    // Número de la página actual que se está solicitando a la API
    private var currentPage = 1
    // Número de resultados que se cargan por página
    private let itemsPerPage = 9	
    // Bandera que indica si se pueden cargar más páginas (si ya se llegó al final)
    private var canLoadMorePages = true
    // Conjunto que contiene las suscripciones de Combine para poder cancelarlas cuando sea necesario
    private var cancellables = Set<AnyCancellable>()

    // Método que verifica si es necesario cargar más personas dependiendo de la persona actual
    func loadMorePeopleIfNeeded(currentPerson person: Person?) {
        // Si no hay persona actual (persona es nil), se carga la primera página
        guard let person = person else {
            loadPeople()
            return
        }

        // Calcula el índice del último elemento (umbral para cargar más)
        let thresholdIndex = people.index(people.endIndex, offsetBy: -1)
        // Si la persona actual es la última de la lista, se cargan más personas
        if people.firstIndex(where: { $0.id == person.id }) == thresholdIndex {
            loadPeople()
        }
    }

    // Método que carga personas desde la API
    func loadPeople() {
        // Verifica si ya se está cargando o si ya no se pueden cargar más páginas
        guard !isLoading && canLoadMorePages else { return }

        // Marca que se está iniciando una carga
        isLoading = true

        // Construye la URL con la página actual y el número de resultados por página
        let urlString = "https://randomuser.me/api/?page=\(currentPage)&results=\(itemsPerPage)"
        guard let url = URL(string: urlString) else {
            print("URL inválida")  // Imprime un error si la URL es inválida
            isLoading = false      // Marca como que ya no se está cargando
            return
        }

        // Realiza la solicitud a la API usando Combine
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)  // Extrae los datos de la respuesta HTTP
            .decode(type: Results.self, decoder: JSONDecoder())  // Decodifica los datos en el tipo `Results`
            .receive(on: DispatchQueue.main)  // Asegura que la actualización de la UI ocurra en el hilo principal
            .sink { completion in
                // Siempre que se complete la solicitud, ya sea con éxito o error, marcamos como que ya no estamos cargando
                self.isLoading = false
                // Si hubo un error en la solicitud, lo imprime
                if case .failure(let error) = completion {
                    print("Error al cargar datos: \(error.localizedDescription)")
                }
            } receiveValue: { results in
                // Al recibir los resultados exitosamente, agrega las nuevas personas a la lista actual
                self.people.append(contentsOf: results.results)
                // Incrementa el número de página para que la próxima solicitud cargue la siguiente página
                self.currentPage += 1
                // Si no se recibieron más resultados, se marca que ya no hay más páginas por cargar
                if results.results.isEmpty {
                    self.canLoadMorePages = false
                }
            }
            .store(in: &self.cancellables)  // Almacena la suscripción en el conjunto `cancellables`
    }
}
