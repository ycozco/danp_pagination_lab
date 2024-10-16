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
	
