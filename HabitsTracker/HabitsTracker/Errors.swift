import Foundation

//TODO: manage all errors

enum AuthenticationError: Error {
    case emailAlreadyExists
    case usernameAlreadyExists
}

enum DBError: Error {
    
}

extension AuthenticationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emailAlreadyExists:
            return "The email already exists"
        case .usernameAlreadyExists:
            return "The username already exists"
        }
    }
}
