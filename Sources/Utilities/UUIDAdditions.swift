import Foundation
import CryptoKit

extension UUID {
    
    init(hashing value: String, inNamespace namespace: UUID) {
        var digest = Insecure.SHA1()
        withUnsafeBytes(of: namespace.uuid) { (buffer) in
            digest.update(bufferPointer: buffer)
        }
        digest.update(data: Data(value.utf8))
        
        var array = Array(digest.finalize())
        array[6] = (array[6] & 0x0F) | 0x50 // set version number nibble to 5
        array[8] = (array[8] & 0x3F) | 0x80 // reset clock nibbles
        
        // truncate to first 16
        self.init(uuid: (array[0], array[1], array[2], array[3], array[4], array[5], array[6], array[7], array[8], array[9], array[10], array[11], array[12], array[13], array[14], array[15]))
    }
    
}
