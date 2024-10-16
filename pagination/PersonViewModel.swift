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
