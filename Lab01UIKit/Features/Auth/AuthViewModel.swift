import Foundation

final class AuthViewModel {

    enum Mode {
        case login
        case registration
    }

    let mode: Mode
    private let authService: AuthServicing

    init(authService: AuthServicing) {
        self.authService = authService
        self.mode = authService.hasRegisteredUser ? .login : .registration
    }

    var buttonTitle: String {
        switch mode {
        case .login: return L10n.Auth.signIn
        case .registration: return L10n.Auth.signUp
        }
    }

    func submit(username: String, password: String) -> Result<Void, AuthError> {
        do {
            switch mode {
            case .login:
                try authService.login(username: username, password: password)
            case .registration:
                try authService.register(username: username, password: password)
            }
            return .success(())
        } catch let error as AuthError {
            return .failure(error)
        } catch {
            return .failure(.storageFailure)
        }
    }
}
