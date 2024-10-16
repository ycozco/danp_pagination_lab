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
                
                // Email con acción de tap
                Text(person.email)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                    .onTapGesture {
                        if let url = URL(string: "mailto:\(person.email)") {
                            UIApplication.shared.open(url)
                        }
                    }
                
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
