//
//  GitODB.swift
//  RebaseEdit
//
//  Created by Jed Fox on 7/25/21.
//

import SwiftGit2
import Clibgit2

extension Data {
    // https://stackoverflow.com/a/40278391/5244995
    fileprivate init?(fromHexEncodedString string: String) {

        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }

        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        if !even {
            self.append(byte)
        }
        // guard even else { return nil }
    }

}

class ODB {
    var pointer: OpaquePointer!
    deinit { git_odb_free(pointer) }

    init?(from repo: Repository) {
        guard git_repository_odb(&pointer, repo.pointer) == GIT_OK.rawValue else {
            return nil
        }
    }

    func refresh() {
        git_odb_refresh(pointer)
    }

    subscript(id: String) -> OID? {
        guard
            id.unicodeScalars.allSatisfy(CharacterSet(charactersIn: "0123456789abcdefABCDEF").contains),
            id.count <= MemoryLayout.size(ofValue: git_oid().id) * 2,
            let data = Data(fromHexEncodedString: id)
        else { return nil }

        var ids = [git_odb_expand_id()]
        ids[0].type = GIT_OBJECT_ANY
        ids[0].length = UInt16(id.count)
        ids[0].id = git_oid()
        let byteCount = id.count / 2 + (id.count % 2)
        let copied = withUnsafeMutableBytes(of: &ids[0].id) { ptr in
            data.copyBytes(to: ptr, count: byteCount)
        }
        guard copied == byteCount else { return nil }

        git_odb_expand_ids(pointer, &ids, 1)

        if ids[0].length > 0 {
            return OID(ids[0].id)
        } else {
            return nil
        }
    }
}
