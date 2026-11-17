import UIKit

extension UIViewController {

    /// Единственная реализация простого алерта (раньше была скопирована в трёх контроллерах).
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
        present(alert, animated: true)
    }
}
