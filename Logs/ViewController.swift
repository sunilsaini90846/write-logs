//
//  ViewController.swift
//  Logs
//
//  Created by apple  on 24/02/21.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickOnButton(_ sender: UIButton) {
        DispatchQueue.main.async(execute: {() -> Void in
            ApiManager.shared.callGetApi { (response) in
                print(response)
                if let languageMessages = response["languageMessages"] as? [[String:Any]] {
                    for languageMessage in languageMessages {
                        if let messages = languageMessage["messages"] as? [[String:Any]] {
                            for message in messages {
                                self.writeMessages(fileName: languageMessage["languageName"] as! String, msgCode: message["msgCode"] as? String ?? "", message: message["message"] as? String  ?? "")
                            }
                        }
                    }
                }
            }
        })
    }
    
    
    func writeMessages(fileName: String, msgCode:String, message: String) {
        var newLogs = "\"\(msgCode)\"=\"\(message)\";\n"
        let documentDirectory = getDocumentsDirectory()
        print("File Path  ==> \(documentDirectory.path)")
        print(newLogs)
        do {
            let filePath = documentDirectory.appendingPathComponent("language.txt")
            let OldLogs = try String(contentsOf: filePath, encoding: .utf8)
            newLogs = OldLogs+newLogs
            try newLogs.write(to: filePath, atomically: false, encoding: .utf8)
        } catch  {
            print(error)
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    
//    func createFile(x: String) {
//        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            print("file Path == \(documentDirectory)")
//            do
//            {
//                try FileManager.default.createDirectory(atPath: documentDirectory.path, withIntermediateDirectories: true, attributes: nil)
//                let filePath = documentDirectory.appendingPathComponent(documentDirectory)
//                try text.write(to: filePath, atomically: false, encoding: .utf8)
//                UserDefaults.standard.setValue("\(folderArray[0])/\(fileName)", forKey: "\(folderArray[0])")
//            }
//            catch let error as NSError
//            {
//                print("Unable to create directory \(error.debugDescription)")
//            }
//        }
//    }
}

