//
//  LogsFile.swift
//  Logs
//
//  Created by apple  on 25/02/21.
//

import Foundation
class LogsFileManager: NSObject {
    
    private let fileName = "\(Date()).txt"
    private let folderCount = 7
    private var folderArray = [LogsFolderName.apiLog,LogsFolderName.bacnet,LogsFolderName.bacnetLib,LogsFolderName.error,LogsFolderName.firebase,LogsFolderName.basicLogs,LogsFolderName.userDefaults]
    
    public func createLogFolderNdFiles() {
        if let fileCreatedDate = UserDefaults.standard.value(forKey: "fileCreatedDate") as? Date {
            let timeDiff = Int(Date().timeIntervalSince1970 - fileCreatedDate.timeIntervalSince1970)
            if timeDiff >= 86400 {
                UserDefaults.standard.setValue(Date(), forKey: "fileCreatedDate")
                self.createLogFolder()
            }
        } else {
            UserDefaults.standard.setValue(Date(), forKey: "fileCreatedDate")
            self.createLogFolder()
        }
    }
    
    private func createLogFolder() {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            print("file Path == \(documentDirectory)")
            self.createFolder(bubllDirectory: documentDirectory, folderName: folderArray[0])
        }
    }
    
    private func createFolder(bubllDirectory: URL,folderName: String) {
        let text = "Logs"
        if folderArray.count > 0 {
            let DirPath = bubllDirectory.appendingPathComponent(folderName)
            do
            {
                try FileManager.default.createDirectory(atPath: DirPath.path, withIntermediateDirectories: true, attributes: nil)
                let filePath = bubllDirectory.appendingPathComponent("\(folderArray[0])/\(fileName)")
                try text.write(to: filePath, atomically: false, encoding: .utf8)
                UserDefaults.standard.setValue("\(folderArray[0])/\(fileName)", forKey: "\(folderArray[0])")
            }
            catch let error as NSError
            {
                print("Unable to create directory \(error.debugDescription)")
            }
            let fileName = UserDefaults.standard.value(forKey: "\(folderArray[0])")
            self.writeBasicLog(fileName: fileName as! String, className: "LogsFileManager", log: "Created File path= \(String(describing: bubllDirectory))")
            folderArray.remove(at: 0)
            if folderArray.count > 0 {
                self.createFolder(bubllDirectory: bubllDirectory, folderName: folderArray[0])
            }
        } else {
            
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    public func writeBasicLog(fileName: String, className:String,log: String) {
        var newLogs = "\n\nClassName : \(className)\nText : \(log) "
        let documentDirectory = getDocumentsDirectory()
        self.manageSizeOfFolderNdFile(folderName: LogsFolderName.basicLogs)
        let filePath = documentDirectory.appendingPathComponent(fileName)
        do {
            let OldLogs = try String(contentsOf: filePath, encoding: .utf8)
            newLogs = OldLogs+newLogs
            try newLogs.write(to: filePath, atomically: false, encoding: .utf8)
        } catch  {
            print(error)
        }
    }
    
    public func writeMessage(fileName: String, message:String, key: String) {
        var newLogs = ""
        let documentDirectory = getDocumentsDirectory()
        self.manageSizeOfFolderNdFile(folderName: LogsFolderName.basicLogs)
        let filePath = documentDirectory.appendingPathComponent(fileName)
        do {
            let OldLogs = try String(contentsOf: filePath, encoding: .utf8)
            newLogs = OldLogs+newLogs
            try newLogs.write(to: filePath, atomically: false, encoding: .utf8)
        } catch  {
            print(error)
        }
    }
    
    public func writeApiLogs(fileName: String, apiName: String, className:String,request: String, response: String) {
        var newLogs = "\n\n Api URL >>>>>>>>>>>- \(apiName)\n ClassName : \(className)\nRequest: \(request)\n Respose : \(response) "
        let documentDirectory = getDocumentsDirectory()
        let filePath = documentDirectory.appendingPathComponent(fileName)
        do {
            let OldLogs = try String(contentsOf: filePath, encoding: .utf8)
            newLogs = OldLogs+newLogs
            try newLogs.write(to: filePath, atomically: false, encoding: .utf8)
        } catch  {
            print(error)
        }
    }
    
    public func writeError(fileName: String, className:String,log: String) {
        var newLogs = "\n\nClassName : \(className)\nText : \(log) "
        let documentDirectory = getDocumentsDirectory()
        let filePath = documentDirectory.appendingPathComponent(fileName)
        self.deleteFile(fileUrl: filePath)
        do {
            let OldLogs = try String(contentsOf: filePath, encoding: .utf8)
            newLogs = OldLogs+newLogs
            try newLogs.write(to: filePath, atomically: false, encoding: .utf8)
        } catch  {
            print(error)
        }
    }
    
    public func readFile(filePath: URL) -> String {
        var logs = ""
        do {
            logs = try String(contentsOf: filePath, encoding: .utf8)
        } catch  {
            print(error)
        }
        return logs
    }
    
    public func deleteFile(fileUrl:URL) {
        do {
            try FileManager.default.removeItem(at: fileUrl)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }
    }
    
    private func manageSizeOfFolderNdFile(folderName: String) {
        let documentDirectory = getDocumentsDirectory()
        let folderPath = documentDirectory.appendingPathComponent(folderName)
        let isFolderSized = isFolderSizeGreaterThan5MB(folderPath: folderPath)
        if isFolderSized {
            let fileUrl = self.getOldestFile(folderPath:folderPath)
            if fileUrl != folderPath {
                self.deleteFile(fileUrl: fileUrl)
            }
        }
    }
    
    private func isFolderSizeGreaterThan5MB(folderPath:URL) -> Bool {
        
        do {
            if let folderSize = try folderPath.directoryTotalAllocatedSize(includingSubfolders: true) {
                let folderSizeInKB = folderSize/1000
                let folderSizeInMB = folderSizeInKB/1024
                if folderSizeInMB >= 5 {
                    return true
                }
            }
        } catch  {
            print(error)
        }
        return false
    }
    
    private func getOldestFile(folderPath:URL) -> URL {
        let fileManager = FileManager()
        do {
            let directoryContent = try fileManager.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            var fileArray = [MyFile]()
            var oldDateFile = Date()
            for url in directoryContent {
                let resources = try url.resourceValues(forKeys: [.creationDateKey])
                let creationDate = resources.creationDate!
                if oldDateFile > creationDate {
                    oldDateFile = creationDate
                }
                fileArray.append(MyFile(dict: ["creationDate":creationDate,"fileUrl":url]))
            }
            if fileArray.count > 0 {
                for file in fileArray {
                    if file.creationDate == oldDateFile {
                        return file.fileUrl
                    }
                }
            }
        } catch {
            print(error)
        }
        return folderPath
    }
}

class MyFile: NSObject {
    let creationDate:Date!
    let fileUrl: URL!
    
    init(dict:[String:Any]) {
        self.creationDate = (dict["creationDate"] as! Date)
        self.fileUrl = (dict["fileUrl"] as! URL)
    }
}

struct LogsFolderName {
    static let bubll = "Bubll"
    static let apiLog = "ApiLog"
    static let bacnet = "Bacnet"
    static let bacnetLib = "BacnetLib"
    static let error = "Error"
    static let firebase = "Firebase"
    static let basicLogs = "BasicLogs"
    static let userDefaults = "UserDefaults"
}

extension URL {
    
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
    
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }
    
    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize ?? 0) + $0
        }
    }
    
    /// returns the directory total size on disk
    func sizeOnDisk() throws -> String? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil}
        return byteCount + " on disk"
    }
    private static let byteCountFormatter = ByteCountFormatter()
}
