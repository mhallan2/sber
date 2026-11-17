import UIKit

/// Короткая цветная «волна» поверх экрана (успех — зелёная, ошибка — красная).
enum FlashOverlay {

    static func show(
        color: UIColor,
        in view: UIView,
        completion: @escaping () -> Void
    ) {
        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = color
        overlay.alpha = 0
        overlay.isUserInteractionEnabled = false
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(overlay, at: 0)

        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0.2
        }, completion: { _ in
            UIView.animate(withDuration: 0.4, animations: {
                overlay.alpha = 0
            }, completion: { _ in
                overlay.removeFromSuperview()
                completion()
            })
        })
    }
}
