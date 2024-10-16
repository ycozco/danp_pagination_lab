	
// ViewController.swift

import UIKit

class ViewController: UIViewController {

    var tableView: UITableView!
    var people: [Person] = []
    var isLoading = false
    var currentPage = 1
    let itemsPerPage = 5 // Número de resultados por página

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Paginación de Personas"
        view.backgroundColor = .white

        tableView = UITableView(frame: view.bounds)
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        // Cargar datos iniciales
        loadPeople(page: currentPage)
    }

    func loadPeople(page: Int) {
        guard !isLoading else { return }

        isLoading = true

        let urlString = "https://randomuser.me/api/?page=\(page)&results=\(itemsPerPage)"
        guard let url = URL(string: urlString) else {
            print("URL inválida")
            isLoading = false
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.isLoading = false }

            if let error = error {
                print("Error en la solicitud: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No se recibieron datos")
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Results.self, from: data)
                let newPeople = result.results

                DispatchQueue.main.async {
                    self.people.append(contentsOf: newPeople)
                    self.tableView.reloadData()
                }
            } catch {
                print("Error al decodificar JSON: \(error)")
            }
        }

        task.resume()
    }
}

// Extensiones para conformar a los protocolos de UITableView
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: PersonTableViewCell.identifier, for: indexPath) as? PersonTableViewCell else {
            return UITableViewCell()
        }

        let person = people[indexPath.row]
        cell.configure(with: person)

        return cell
    }

    // MARK: - UITableView Delegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == people.count - 1 { // Si es el último elemento
            currentPage += 1
            loadPeople(page: currentPage)
        }
    }
}
