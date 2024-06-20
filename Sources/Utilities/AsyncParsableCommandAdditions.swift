import ArgumentParser
import Foundation

extension AsyncParsableCommand {
    
    @Sendable static func directory(_ argument: String = ".") -> URL {
        URL(fileURLWithPath: argument, isDirectory: true)
    }
    
    @Sendable static func file(_ argument: String) -> URL {
        URL(fileURLWithPath: argument, isDirectory: false)
    }
    
}
