import Foundation

public extension Date {
    var isPast: Bool {
        return self < Date()
    }
}
