import Foundation

/// Enum representing possible errors during authentication.
enum AuthenticationError: Error {
    case emailAlreadyExists
    case usernameAlreadyExists
    case userNotLogged
    case missingCredential
}

/// Enum representing possible errors when interacting with Firestore.
enum DBError: Error {
    case failedUserRetrieval
    case badDBResponse
}

/// Enum representing possible errors on the view or user interface level.
enum ViewError: Error {
    case usernameEmailPasswordNotFound
}

// MARK: - Authentication Error Descriptions

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

// MARK: - Database Error Descriptions

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

// MARK: - View Error Descriptions

extension ViewError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .usernameEmailPasswordNotFound:
            return "No username, email or password found."
        }
    }
}
