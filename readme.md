# Tecnologías Utilizadas y Código Implementado

A continuación, se presenta una explicación detallada de las tecnologías utilizadas en el proyecto, junto con el código implementado. Todo está formateado en Markdown para que puedas copiarlo o descargarlo fácilmente.

---

## **Tecnologías Utilizadas**

1. **SwiftUI**: Framework de Apple para construir interfaces de usuario de forma declarativa.
2. **Combine**: Framework para manejar eventos asíncronos y flujos de datos.
3. **AsyncImage**: Vista de SwiftUI para cargar imágenes de forma asíncrona (disponible en iOS 15 y posteriores).
4. **URLSession y dataTaskPublisher**: Para realizar solicitudes de red y manejar respuestas asíncronas.
5. **Codable**: Protocolo para facilitar la codificación y decodificación de datos en formatos como JSON.
6. **MVVM (Model-View-ViewModel)**: Patrón de arquitectura para separar la lógica de negocio de la interfaz de usuario.
7. **Swift Property Wrappers**: `@StateObject`, `@Published`, etc., para manejar el estado y las actualizaciones en SwiftUI.
8. **List, ForEach, NavigationLink**: Vistas de SwiftUI para construir listas y navegar entre vistas.

---

## **Implementación en el Código**

### **1. Modelo de Datos con Codable**

**Archivo:** `Person.swift`

Utilizamos estructuras que conforman al protocolo `Codable` para mapear los datos JSON recibidos de la API a objetos Swift.

```swift
// Person.swift

import Foundation

struct Results: Codable {
    let results: [Person]
    let info: Info
}

struct Person: Identifiable, Codable {
    var id: String { login.uuid }
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob: DOB
    let phone: String
    let cell: String
    let picture: Picture
    let nat: String
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: Postcode
    let coordinates: Coordinates
    let timezone: Timezone
    
    // Propiedad calculada para obtener el código postal como String
    var postcodeString: String {
        switch postcode {
        case .int(let value):
            return String(value)
        case .string(let value):
            return value
        }
    }
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable {
    let offset: String
    let description: String
}

struct Login: Codable {
    let uuid: String
}

struct DOB: Codable {
    let date: String
    let age: Int
}

struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}

struct Info: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

// Manejo de código postal que puede ser Int o String
enum Postcode: Codable {
    case int(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intPostcode = try? container.decode(Int.self) {
            self = .int(intPostcode)
        } else if let stringPostcode = try? container.decode(String.self) {
            self = .string(stringPostcode)
        } else {
            throw DecodingError.typeMismatch(Postcode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "El tipo de Postcode no coincide"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let intPostcode):
            try container.encode(intPostcode)
        case .string(let stringPostcode):
            try container.encode(stringPostcode)
        }
    }
}
```

**Explicación:**

- **Codable**: Permite decodificar automáticamente el JSON en estas estructuras.
- **Identifiable**: El modelo `Person` conforma a `Identifiable` para que pueda ser usado en vistas como `ForEach`.
- **Propiedad `id`**: Utilizamos `login.uuid` como identificador único para cada persona.
- **Manejo de `postcode`**: Utilizamos una enumeración para manejar casos donde `postcode` puede ser un `Int` o un `String`.

---

### **2. Vista Modelo (ViewModel) con Combine**

**Archivo:** `PersonViewModel.swift`

El ViewModel maneja la lógica de negocio, incluyendo la carga de datos y la paginación.

```swift
// PersonViewModel.swift

import Foundation
import Combine

class PersonViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var isLoading = false

    private var currentPage = 1
    private let itemsPerPage = 5
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()

    func loadMorePeopleIfNeeded(currentPerson person: Person?) {
        guard let person = person else {
            loadPeople()
            return
        }

        let thresholdIndex = people.index(people.endIndex, offsetBy: -1)
        if people.firstIndex(where: { $0.id == person.id }) == thresholdIndex {
            loadPeople()
        }
    }

    func loadPeople() {
        guard !isLoading && canLoadMorePages else { return }

        isLoading = true

        let urlString = "https://randomuser.me/api/?page=\(currentPage)&results=\(itemsPerPage)"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Results.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("Error al cargar datos: \(error.localizedDescription)")
                }
            } receiveValue: { results in
                self.people.append(contentsOf: results.results)
                self.currentPage += 1
                if results.results.isEmpty {
                    self.canLoadMorePages = false
                }
            }
            .store(in: &self.cancellables)
    }
}
```

**Explicación:**

- **ObservableObject y @Published**: El ViewModel conforma a `ObservableObject`, y las propiedades `people` e `isLoading` están anotadas con `@Published` para que las vistas que las observan se actualicen automáticamente cuando cambien.
- **Combine y dataTaskPublisher**: Utilizamos `URLSession` y su método `dataTaskPublisher` para realizar la solicitud de red y manejar la respuesta de forma reactiva.
- **Manejo de Paginación**:
  - `currentPage`: Lleva la cuenta de la página actual que se está cargando.
  - `itemsPerPage`: Número de resultados por página.
  - `canLoadMorePages`: Indica si hay más páginas para cargar.
  - `loadMorePeopleIfNeeded`: Se llama cuando la vista necesita determinar si debe cargar más datos, típicamente cuando el usuario se acerca al final de la lista.

---

### **3. Vista Principal con SwiftUI**

**Archivo:** `ContentView.swift`

Esta vista muestra la lista de personas y maneja la interacción del usuario.

```swift
// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PersonViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.people) { person in
                    NavigationLink(destination: PersonDetailView(person: person)) {
                        PersonRowView(person: person)
                            .onAppear {
                                viewModel.loadMorePeopleIfNeeded(currentPerson: person)
                            }
                    }
                }

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Personas")
        }
        .onAppear {
            viewModel.loadPeople()
        }
    }
}
```

**Explicación:**

- **@StateObject**: Instancia el ViewModel y se asegura de que persista durante el ciclo de vida de la vista.
- **NavigationView y NavigationLink**: Permiten la navegación entre la lista y la vista de detalle de cada persona.
- **List y ForEach**: Muestran la lista de personas. Cada elemento se compone de una `PersonRowView`.
- **onAppear**: Llama a `loadMorePeopleIfNeeded` cuando una fila aparece, para determinar si se deben cargar más datos.
- **Indicador de carga**: Muestra un `ProgressView` al final de la lista si `isLoading` es `true`.

---

### **4. Vista de Fila Personalizada**

**Archivo:** `PersonRowView.swift`

Representa cada persona en la lista.

```swift
// PersonRowView.swift

import SwiftUI

struct PersonRowView: View {
    let person: Person

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: person.picture.thumbnail)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())

            VStack(alignment: .leading) {
                Text("\(person.name.title) \(person.name.first) \(person.name.last)")
                    .font(.headline)
                Text(person.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 5)
        }
    }
}
```

**Explicación:**

- **AsyncImage**: Carga la imagen de forma asíncrona desde la URL proporcionada.
- **Estilo de la imagen**: Se muestra como un círculo con un tamaño fijo.
- **VStack y HStack**: Organizan los elementos de texto y la imagen horizontal y verticalmente.
- **Estilo de texto**: Se utiliza `font` y `foregroundColor` para dar formato al texto.

---

### **5. Vista de Detalle de la Persona**

**Archivo:** `PersonDetailView.swift`

Muestra información detallada de la persona seleccionada.

```swift
// PersonDetailView.swift

import SwiftUI

struct PersonDetailView: View {
    let person: Person

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Foto de perfil grande
                AsyncImage(url: URL(string: person.picture.large)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                .clipShape(Circle())

                // Nombre completo
                Text("\(person.name.title) \(person.name.first) \(person.name.last)")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)

                // Correo electrónico
                Text(person.email)
                    .font(.title2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Divider()

                // Información personal
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Género:")
                            .fontWeight(.bold)
                        Text(person.gender.capitalized)
                    }

                    HStack {
                        Text("Edad:")
                            .fontWeight(.bold)
                        Text("\(person.dob.age)")
                    }

                    HStack {
                        Text("Fecha de Nacimiento:")
                            .fontWeight(.bold)
                        Text(formatDate(person.dob.date))
                    }

                    HStack {
                        Text("Nacionalidad:")
                            .fontWeight(.bold)
                        Text(person.nat)
                    }
                }

                Divider()

                // Información de contacto
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Teléfono:")
                            .fontWeight(.bold)
                        Text(person.phone)
                    }

                    HStack {
                        Text("Celular:")
                            .fontWeight(.bold)
                        Text(person.cell)
                    }
                }

                Divider()

                // Ubicación
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ubicación")
                        .font(.headline)
                        .padding(.bottom, 5)

                    HStack {
                        Text("Dirección:")
                            .fontWeight(.bold)
                        Text("\(person.location.street.number) \(person.location.street.name)")
                    }

                    HStack {
                        Text("Ciudad:")
                            .fontWeight(.bold)
                        Text(person.location.city)
                    }

                    HStack {
                        Text("Estado:")
                            .fontWeight(.bold)
                        Text(person.location.state)
                    }

                    HStack {
                        Text("País:")
                            .fontWeight(.bold)
                        Text(person.location.country)
                    }

                    HStack {
                        Text("Código Postal:")
                            .fontWeight(.bold)
                        Text(person.location.postcodeString)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle(person.name.first)
        }
    }

    // Función para formatear la fecha
    func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
}
```

**Explicación:**

- **ScrollView**: Permite que el contenido sea desplazable en caso de que exceda la altura de la pantalla.
- **Presentación de Información**:
  - **Imagen de perfil**: Se muestra en grande y centrada.
  - **Datos personales**: Incluye género, edad, fecha de nacimiento y nacionalidad.
  - **Información de contacto**: Muestra el teléfono y el celular.
  - **Ubicación**: Presenta detalles de la dirección, ciudad, estado, país y código postal.
- **Estilos y Formatos**:
  - **Dividers**: Separan visualmente las secciones de información.
  - **Font y fontWeight**: Se utilizan para resaltar títulos y etiquetas.
  - **Función `formatDate`**: Convierte la fecha en formato ISO8601 a un formato legible para el usuario.

---

### **6. Manejo de Datos con URLSession y Combine**

En el `PersonViewModel`, utilizamos `URLSession` y Combine para manejar las solicitudes de red y procesar las respuestas.

**Fragmento relevante:**

```swift
URLSession.shared.dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: Results.self, decoder: JSONDecoder())
    .receive(on: DispatchQueue.main)
    .sink { completion in
        self.isLoading = false
        if case .failure(let error) = completion {
            print("Error al cargar datos: \(error.localizedDescription)")
        }
    } receiveValue: { results in
        self.people.append(contentsOf: results.results)
        self.currentPage += 1
        if results.results.isEmpty {
            self.canLoadMorePages = false
        }
    }
    .store(in: &self.cancellables)
```

**Explicación:**

- **dataTaskPublisher**: Realiza una solicitud HTTP GET al URL proporcionado.
- **Operadores de Combine**:
  - **map(\.data)**: Extrae los datos de la respuesta.
  - **decode**: Decodifica los datos JSON en el tipo `Results`.
  - **receive(on: DispatchQueue.main)**: Asegura que las actualizaciones de la interfaz se realicen en el hilo principal.
- **sink**: Suscribe al publisher y maneja tanto la finalización como los valores recibidos.
- **store**: Almacena la suscripción en `cancellables` para mantenerla viva durante la vida del ViewModel.

---

### **7. Manejo de Estado y Actualizaciones en SwiftUI**

- **@StateObject** en `ContentView`: Asegura que el ViewModel se inicialice solo una vez y persista durante el ciclo de vida de la vista.
- **@Published** en `PersonViewModel`: Permite que las vistas que observan estas propiedades se actualicen automáticamente cuando cambian.

---

### **8. Navegación entre Vistas**

- **NavigationView**: Envuelve la vista principal para habilitar la navegación.
- **NavigationLink**: Permite navegar a `PersonDetailView` al tocar una fila en la lista.

---

## **Resumen de la Implementación**

- **Arquitectura MVVM**: Separación clara entre los modelos de datos, la lógica de negocio y las vistas.
- **Carga Asíncrona de Datos**: Uso de `URLSession` y Combine para realizar solicitudes de red sin bloquear el hilo principal.
- **Actualizaciones Reactivas**: Las vistas se actualizan automáticamente al cambiar los datos gracias a `@Published` y `ObservableObject`.
- **Interfaz de Usuario Declarativa**: Construcción de interfaces con SwiftUI, lo que facilita la comprensión y mantenimiento del código.
- **Paginación Automática**: Implementación de lógica para cargar más datos a medida que el usuario se desplaza al final de la lista.

---

## **Consideraciones Finales**

- **Manejo de Errores**: En la implementación actual, los errores se imprimen en la consola. En una aplicación de producción, sería recomendable mostrar mensajes al usuario o implementar un sistema de registro de errores más robusto.
- **Optimización**: Para mejorar la experiencia del usuario, se podrían agregar indicadores de carga más sofisticados, cacheo de imágenes y manejo de estados de vacío o sin conexión.
- **Compatibilidad**: Asegúrate de que tu proyecto está configurado para iOS 15 o posterior para utilizar `AsyncImage`.

---

## **Recursos Adicionales**

- **Documentación de SwiftUI**: [Apple Developer - SwiftUI](https://developer.apple.com/documentation/swiftui)
- **Guía de Combine**: [Using Combine](https://developer.apple.com/documentation/combine)
- **Random User API**: [randomuser.me](https://randomuser.me/)

---
