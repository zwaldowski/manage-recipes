import ArgumentParser
import Foundation

extension AsyncParsableCommand {
    
    static func directory(_ argument: String = ".") -> URL {
        URL(fileURLWithPath: argument, isDirectory: true)
    }
    
    static func file(_ argument: String) -> URL {
        URL(fileURLWithPath: argument, isDirectory: false)
    }
    
}
