//
//  TestFile.swift
//  BackgroundApp
//
//  Created by hsf on 2024/11/11.
//

import Foundation

class TestFile {
    static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter
    }()
    private static func filter(files: [URL]) -> [URL] {
        let prefix = "test_"
        let suffix = ".txt"
        let filteredFiles = files.compactMap { fileURL -> (URL, Date)? in
            let fileName = fileURL.lastPathComponent
            guard fileName.hasPrefix(prefix), fileName.hasSuffix(suffix) else {
                return nil
            }
            let start = fileName.index(fileName.startIndex, offsetBy: prefix.count)
            let end = fileName.index(fileName.endIndex, offsetBy: -suffix.count)
            if let creationDate = try? fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate {
                return (fileURL, creationDate)
            }
            return nil
        }.sorted { $0.1 < $1.1 }.map { $0.0 }
        return filteredFiles
    }
}

// MARK: - 生成「测试文件」，存入 Document 中
extension TestFile {
    static func generate(time: Date) -> Bool {
        let timeStr = formatter.string(from: time)
        let fileName = "test_\(timeStr).txt"
        let kb = Int.random(in: 100...1024*10)
        if let _ = generate(fileName: fileName, kb: kb) {
            print("TestFile:", "生成文件成功: \(fileName)(\(kb) KB)")
            return true
        } else {
            print("TestFile:", "生成文件失败: \(fileName)(\(kb) KB")
            return false
        }
    }
    
    private static func generate(fileName: String, kb: Int) -> URL? {
        let fileManager = FileManager.default
        // fileURL
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("TestFile:", "无法获取Document目录路径")
            return nil
        }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        // fakeData
        let data = fakeData(sizeInKB: kb)
        do {
            try data.write(to: fileURL)
            print("TestFile:", "文件成功创建: \(fileURL.path)")
            return fileURL
        } catch {
            print("TestFile:", "无法写入文件: \(error)")
            return nil
        }
    }
    
    private static func fakeData(sizeInKB: Int) -> Data {
        // 根据给定大小生成虚拟数据
        let dataSize = sizeInKB * 1024  // 将KB转换为字节
        let fakeData = Data(repeating: 0x00, count: dataSize)  // 使用0x00填充
        return fakeData
    }
}


// MARK: - 将「测试文件」备份到 Cache 中
extension TestFile {
    static func backup() -> Bool {
        print("TestFile:", "将「测试文件」备份到Cache中")
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("TestFile:", "无法获取 Document 或 Cache 目录")
            return false
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            let filteredFiles = filter(files: files)
            for fileURL in filteredFiles {
                let destinationURL = cacheDirectory.appendingPathComponent(fileURL.lastPathComponent)
                do {
                    try fileManager.copyItem(at: fileURL, to: destinationURL)
                    
                } catch {
                    print("TestFile:", "备份文件到 Cache 目录失败：\(fileURL.lastPathComponent)，错误：\(error)")
                    return false
                }
            }
            print("TestFile:", "备份成功")
            return true
        } catch {
            print("TestFile:", "读取 Document 目录内容失败：\(error)")
            return false
        }
    }
}


// MARK: - 将「测试文件」上传到服务器
extension TestFile {
    static func upload() -> Bool {
        print("TestFile:", "将「测试文件」上传到服务器")
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let downloadDirectory = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            print("TestFile:", "无法获取 Document 或 Download 目录")
            return false
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            let filteredFiles = filter(files: files)
            for fileURL in filteredFiles {
                let destinationURL = downloadDirectory.appendingPathComponent(fileURL.lastPathComponent)
                if simulateUpload(fileURL: fileURL, to: destinationURL) {
                    do {
                        try fileManager.removeItem(at: fileURL)
                    } catch {
                        print("TestFile:", "文件上传失败： \(fileURL.lastPathComponent) ，错误：\(error)")
                        return false
                    }
                } else {
                    print("TestFile:", "文件 \(fileURL.lastPathComponent) 上传失败")
                    return false
                }
            }
            print("TestFile:", "上传成功")
            return true
        } catch {
            print("TestFile:", "读取 Document 目录内容失败：\(error)")
            return false
        }
    }
    
    // 模拟上传操作的函数
    private static func simulateUpload(fileURL: URL, to destinationURL: URL) -> Bool {
        Thread.sleep(forTimeInterval: TimeInterval.random(in: 1...5))
        do {
            let fileManager = FileManager.default
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            print("TestFile:", "文件上传到 Download 目录成功： \(fileURL.lastPathComponent) ")
            return true
        } catch {
            print("TestFile:", "文件上传到 Download 目录失败：\(fileURL.lastPathComponent)，错误：\(error)")
            return false
        }
    }
}


// MARK: - 将「测试文件」还原到 Document 中，清空 Cache
extension TestFile {
    static func restore() -> Bool {
        print("TestFile:", "将「测试文件」还原到 Document 中")
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("TestFile:", "无法获取 Document 或 Cache 目录")
            return false
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            let filteredFiles = filter(files: files)
            for fileURL in filteredFiles {
                let destinationURL = documentDirectory.appendingPathComponent(fileURL.lastPathComponent)
                do {
                    try fileManager.copyItem(at: fileURL, to: destinationURL)
                } catch {
                    print("TestFile:", "还原文件失败：\(fileURL.lastPathComponent)，错误：\(error)")
                    return false
                }
            }
            print("TestFile:", "还原成功")
            return true
        } catch {
            print("TestFile:", "读取 Document 目录内容失败：\(error)")
            return false
        }
    }
}


// MARK: - 清空
extension TestFile {
    static func cleanDocument() -> Bool {
        print("TestFile:", "清空 Document 中的「测试文件」")
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("TestFile:", "无法获取 Document 目录")
            return false
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            let filteredFiles = filter(files: files)
            for fileURL in filteredFiles {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch {
                    print("TestFile:", "删除文件失败：\(fileURL.lastPathComponent)，错误：\(error)")
                    return false
                }
            }
            print("TestFile:", "清空成功")
            return true
        } catch {
            print("TestFile:", "读取 Document 目录内容失败：\(error)")
            return false
        }
    }
    
    static func cleanCache() -> Bool {
        print("TestFile:", "清空 Cache 中的「测试文件」")
        let fileManager = FileManager.default
        guard let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("TestFile:", "无法获取 Cache 目录")
            return false
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            let filteredFiles = filter(files: files)
            for fileURL in filteredFiles {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch {
                    print("TestFile:", "删除文件失败：\(fileURL.lastPathComponent)，错误：\(error)")
                    return false
                }
            }
            print("TestFile:", "清空成功")
            return true
        } catch {
            print("TestFile:", "读取 Cache 目录内容失败：\(error)")
            return false
        }
    }
}
