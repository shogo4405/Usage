import Foundation

extension Usage {
    public class Monitor {
        let fileHandler: FileHandle

        public private(set) var running: Bool = false
        private let queue: DispatchQueue = .init(label: "Usage.Monitor.queue")
        private var timeBase: mach_timebase_info = mach_timebase_info()

        public init(_ forWritingTo: URL) throws {
            mach_timebase_info(&timeBase)
            fileHandler = try .init(forWritingTo: forWritingTo)
        }

        public func startRunning(_ hz: Double) {
            queue.async {
                guard !self.running else {
                    return
                }
                self.running = true
                self.run(hz)
            }
        }

        public func stopRunning() {
            queue.async {
                guard self.running else {
                    return
                }
                self.running = false
                self.fileHandler.closeFile()
            }
        }

        func run(_ hz: Double) {
            while running {
                let startTime = mach_absolute_time()
                exectute()
                let diff = (mach_absolute_time() - startTime)
                Thread.sleep(forTimeInterval: (1 / hz) * 1000000)
            }
        }

        func exectute() {
            guard let cpu = Usage.cpu(), let memory = Usage.memory() else {
                return
            }
            let timestamp = Date().timeIntervalSince1970
            let line = "\(timestamp),\(cpu.user),\(cpu.system),\(cpu.nice),\(cpu.idle),\(memory)\n"
            if let line = line.data(using: .utf8) {
                fileHandler.write(line)
            }
        }
    }
}