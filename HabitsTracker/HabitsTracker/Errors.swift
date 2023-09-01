import Foundation

//TODO: manage all errors

enum AuthenticationError: Error {
    case emailAlreadyExists
    case usernameAlreadyExists
    case userNotLogged
    case missingCredential
}

enum DBError: Error {
    case failedUserRetrieval
    case badDBResponse
}

enum ViewError: Error {
    case usernameEmailPasswordNotFound
}

extension AuthenticationError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .emailAlreadyExists:
            return "The email already exists."
        case .usernameAlreadyExists:
            return "The username already exists."
        case .userNotLogged:
            return "You are not logged in."
        case .missingCredential:
            return "Missing credentials."
        }
    }
}

extension DBError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .failedUserRetrieval:
            return "Failed to retrieve or convert current User information."
        case .badDBResponse:
            return "Failed to to connect to the Database."
        }
        
    }
}

extension ViewError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .usernameEmailPasswordNotFound:
            return "No username, email or password found."
        }
    }
}
