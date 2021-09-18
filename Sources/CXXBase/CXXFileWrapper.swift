//
//  File.swift
//  File
//
//  Created by Morgan McColl on 17/9/21.
//

import Foundation

public final class CXXFileWrapper: FileWrapper {
    
    var machine: Machine
    
    init(directoryWithFileWrappers childrenByPreferredName: [String : FileWrapper], machine: Machine) {
        self.machine = machine
        super.init(directoryWithFileWrappers: childrenByPreferredName)
    }
    
    required init?(coder inCoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func write(to url: URL, options: FileWrapper.WritingOptions = [], originalContentsURL: URL?) throws {
        let components = url.lastPathComponent.components(separatedBy: ".machine")
        guard
            components.count >= 1,
            components[0] != "",
            isDirectory
        else {
            return try super.write(to: url, options: options, originalContentsURL: originalContentsURL)
        }
        let machineName = components[0]
        if machine.name == machineName {
            return try super.write(to: url, options: options, originalContentsURL: originalContentsURL)
        }
        machine.name = machineName
        machine.path = url
        guard let newWrapper = CXXGenerator().generate(machine: machine)?.1 else {
            fatalError("Cannot generate new machine files")
        }
        return try newWrapper.write(to: url, options: options, originalContentsURL: originalContentsURL)
    }
    
//    public override func write(to url: URL, options: FileWrapper.WritingOptions = [], originalContentsURL: URL?) throws {
//        guard let oldDir = self.filename else {
//            fatalError("Can't get old name")
//        }
//        let components = url.lastPathComponent.components(separatedBy: ".machine")
//        let currentComponents = oldDir.components(separatedBy: ".machine")
//        guard
//            components.count >= 1,
//            components[0] != "",
//            currentComponents.count >= 1,
//            currentComponents[0] != "",
//            isDirectory
//        else {
//            return try super.write(to: url, options: options, originalContentsURL: originalContentsURL)
//        }
//        let machineName = components[0]
//        let oldName = currentComponents[0]
//        self.filename = changeFileName(oldPrefix: oldName, newPrefix: machineName, name: oldDir)
//        if let existingWrappers = self.fileWrappers {
//            let wrappers = convertExistingWrappers(wrappers: existingWrappers, oldName: oldName, newName: machineName)
//            let newFileWrapper = FileWrapper(directoryWithFileWrappers: wrappers)
//            newFileWrapper.filename = self.filename
//            try newFileWrapper.write(to: url, options: options, originalContentsURL: originalContentsURL)
//            return
//        }
//        try super.write(to: url, options: options, originalContentsURL: originalContentsURL)
//    }
    
//    private func writeFileWrapper(wrapper: FileWrapper, root: URL) throws {
//        guard let name = wrapper.filename else {
//            return
//        }
//        guard let subFiles = wrapper.fileWrappers else {
//            let newRoot = root.appendingPathComponent(name, isDirectory: false)
//            try wrapper.write(to: newRoot, options: .atomic, originalContentsURL: nil)
//            return
//        }
//        let newRoot = root.appendingPathComponent(name, isDirectory: true)
//        try subFiles.forEach {
//            try writeFileWrapper(wrapper: $0.value, root: newRoot)
//        }
//    }
//
//    private func changeFileName(oldPrefix: String, newPrefix: String, name: String) -> String {
//        name.replacingOccurrences(of: oldPrefix, with: newPrefix, options: .anchored, range: String.Index(utf16Offset: 0, in: name)..<String.Index(utf16Offset: oldPrefix.count, in: name))
//    }
//
//    private func convertExistingWrappers(wrappers: [String: FileWrapper], oldName: String, newName: String) -> [String: FileWrapper] {
//        if oldName == newName {
//            return wrappers
//        }
//        return Dictionary(uniqueKeysWithValues: wrappers.map { (keyVal) -> (String, FileWrapper) in
//            let key = keyVal.key
//            let val = keyVal.value
//            if !key.contains(oldName) {
//                return (key, val)
//            }
//            let newKey = changeFileName(oldPrefix: oldName, newPrefix: newName, name: key)
//            val.filename = newKey
//            if !val.isDirectory {
//                return (newKey, val)
//            }
//            let valWrappers = convertExistingWrappers(wrappers: val.fileWrappers ?? [:], oldName: oldName, newName: newName)
//            let newVal = FileWrapper(directoryWithFileWrappers: valWrappers)
//            return (newKey, newVal)
//        })
//    }
    
}
