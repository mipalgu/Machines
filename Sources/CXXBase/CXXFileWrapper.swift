//
//  File.swift
//  File
//
//  Created by Morgan McColl on 17/9/21.
//

import Foundation

final class CXXFileWrapper: FileWrapper {
    
    override func write(to url: URL, options: FileWrapper.WritingOptions = [], originalContentsURL: URL?) throws {
        if #available(macOSApplicationExtension 10.11, *) {
            guard url.hasDirectoryPath else {
                fatalError("Trying to save a CXX machine to a file path")
            }
        }
        guard let oldDir = self.filename else {
            fatalError("Can't get old name")
        }
        let components = url.lastPathComponent.components(separatedBy: ".machine")
        let currentComponents = oldDir.components(separatedBy: ".machine")
        guard
            components.count >= 1,
            components[0] != "",
            currentComponents.count >= 1,
            currentComponents[0] != "",
            isDirectory
        else {
            return try super.write(to: url, options: options, originalContentsURL: originalContentsURL)
        }
        let machineName = components[0]
        let oldName = currentComponents[0]
        self.filename = changeFileName(oldPrefix: oldName, newPrefix: machineName, name: oldDir)
        if let existingWrappers = self.fileWrappers {
            let wrappers = convertExistingWrappers(wrappers: existingWrappers, oldName: oldName, newName: machineName)
            try FileWrapper(directoryWithFileWrappers: wrappers).write(to: url, options: options, originalContentsURL: originalContentsURL)
        }
    }
    
    private func changeFileName(oldPrefix: String, newPrefix: String, name: String) -> String {
        name.replacingOccurrences(of: oldPrefix, with: newPrefix, options: .anchored, range: String.Index(utf16Offset: 0, in: name)..<String.Index(utf16Offset: oldPrefix.count, in: name))
    }
    
    private func convertExistingWrappers(wrappers: [String: FileWrapper], oldName: String, newName: String) -> [String: FileWrapper] {
        Dictionary(uniqueKeysWithValues: wrappers.map { (keyVal) -> (String, FileWrapper) in
            let key = keyVal.key
            let val = keyVal.value
            if !key.contains(oldName) {
                return (key, val)
            }
            let newKey = changeFileName(oldPrefix: oldName, newPrefix: newName, name: key)
            if newKey == key {
                return (key, val)
            }
            val.filename = newKey
            if !val.isDirectory {
                return (newKey, val)
            }
            let valWrappers = convertExistingWrappers(wrappers: val.fileWrappers ?? [:], oldName: oldName, newName: newName)
            let newVal = FileWrapper(directoryWithFileWrappers: valWrappers)
            return (newKey, newVal)
        })
    }
    
}
