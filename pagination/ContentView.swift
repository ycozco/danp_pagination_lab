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
	
