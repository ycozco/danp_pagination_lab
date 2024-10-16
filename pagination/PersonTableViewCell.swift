// PersonTableViewCell.swift

import UIKit

class PersonTableViewCell: UITableViewCell {

    static let identifier = "PersonTableViewCell"

    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // Configura el aspecto de la imagen (redondeada, borde, etc.)
        imageView.layer.cornerRadius = 30
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Inicializador y configuración de la celda
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Agregar subviews
        contentView.addSubview(personImageView)
        contentView.addSubview(nameLabel)

        // Configurar AutoLayout
        NSLayoutConstraint.activate([
            personImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            personImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            personImageView.widthAnchor.constraint(equalToConstant: 60),
            personImageView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.leadingAnchor.constraint(equalTo: personImageView.trailingAnchor, constant: 15),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Método para configurar la celda
    func configure(with person: Person) {
        nameLabel.text = "\(person.name.title) \(person.name.first) \(person.name.last)"
        if let url = URL(string: person.picture.thumbnail) {
            // Carga de imagen asíncrona (considera usar SDWebImage para producción)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.personImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        personImageView.image = nil
        nameLabel.text = nil
    }
}
