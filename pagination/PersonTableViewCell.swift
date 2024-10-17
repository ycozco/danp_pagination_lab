import UIKit

// Clase para representar una celda personalizada de la tabla que mostrará la información de una persona
class PersonTableViewCell: UITableViewCell {

    // Identificador estático para reutilización de la celda
    static let identifier = "PersonTableViewCell"

    // UIImageView para mostrar la imagen de la persona
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill  
        // Modo de ajuste para que la imagen llene el espacio respetando la proporción
        imageView.clipsToBounds = true            
        // Asegura que la imagen no se salga de los bordes del UIImageView
        imageView.layer.cornerRadius = 30         
        // Hace que las esquinas de la imagen sean redondeadas (en este caso, un círculo)
        imageView.translatesAutoresizingMaskIntoConstraints = false  
        // Deshabilita las restricciones automáticas para usar Auto Layout
        return imageView
    }()

    // UILabel para mostrar el nombre de la persona
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)  
        // Configuración de la fuente del texto, tamaño y estilo (negrita)
        label.translatesAutoresizingMaskIntoConstraints = false    
        // Deshabilita las restricciones automáticas para usar Auto Layout
        return label
    }()

    // Inicializador personalizado de la celda, usado al crear la celda programáticamente
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Añade las subviews (componentes) al contentView de la celda
        contentView.addSubview(personImageView)  
        // Añade la imagen de la persona
        contentView.addSubview(nameLabel)        
        // Añade la etiqueta de nombre

        // Configuración de las restricciones Auto Layout para organizar los elementos en la celda
        NSLayoutConstraint.activate([
            // Configuración para la imagen (personImageView)
            personImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),  // Margen izquierdo de 10 puntos
            personImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),                // Centra verticalmente la imagen en la celda
            personImageView.widthAnchor.constraint(equalToConstant: 60),                                 // Ancho fijo de 60 puntos
            personImageView.heightAnchor.constraint(equalToConstant: 60),                                // Alto fijo de 60 puntos (imagen será cuadrada)

            // Configuración para la etiqueta de nombre (nameLabel)
            nameLabel.leadingAnchor.constraint(equalTo: personImageView.trailingAnchor, constant: 15),    // Margen de 15 puntos a la derecha de la imagen
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),                      // Centra verticalmente el texto en la celda
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)       // Margen derecho de 10 puntos
        ])
    }

    // Este inicializador no está implementado porque solo se usa si la celda se carga desde un archivo XIB o Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Método para configurar la celda con la información de un objeto Person
    func configure(with person: Person) {
        // Configura el texto del label con el nombre completo de la persona
        nameLabel.text = "\(person.name.title) \(person.name.first) \(person.name.last)"
        
        // Verifica si hay una URL válida para la imagen en miniatura (thumbnail) de la persona
        if let url = URL(string: person.picture.thumbnail) {
            // Carga la imagen de manera asíncrona en un hilo secundario (background thread)
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {  // Intenta descargar los datos de la imagen desde la URL
                    DispatchQueue.main.async {
                        // Actualiza la imagen en la interfaz de usuario en el hilo principal
                        self.personImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    // Método que prepara la celda para su reutilización, reinicia la imagen y el texto para evitar contenido previo
    override func prepareForReuse() {
        super.prepareForReuse()
        // Elimina la imagen anterior para evitar que aparezca en la reutilización
        personImageView.image = nil
        // Limpia el texto del nombre
        nameLabel.text = nil
        
    }
}
