import Foundation

public struct Usage {
    static let machHost = mach_host_self()
    static let hostCPULoadInfoCount = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    static let machTaskBasicInfoCount = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

    private static var loadPrevious = host_cpu_load_info()

    public enum Unit: UInt64 {
        case none = 1
        case KiB = 1024
        case MiB = 1048576
    }

    public static func cpu() -> (system : Double, user: Double, idle: Double, nice: Double) {
        let load = Usage.hostCPULoadInfo()
        defer {
            loadPrevious = load
        }
        let user = Double(load.cpu_ticks.0 - loadPrevious.cpu_ticks.0)
        let sys  = Double(load.cpu_ticks.1 - loadPrevious.cpu_ticks.1)
        let idle = Double(load.cpu_ticks.2 - loadPrevious.cpu_ticks.2)
        let nice = Double(load.cpu_ticks.3 - loadPrevious.cpu_ticks.3)
        let total = sys + user + nice + idle
        return (sys / total * 100.0, user / total * 100.0, idle / total * 100, nice / total * 100)
    }

    public static func hostCPULoadInfo() -> host_cpu_load_info {
        var count = hostCPULoadInfoCount
        var info = host_cpu_load_info()
        _ = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(machHost, HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        return info
    }

    public static func machTaskBasicInfo() -> mach_task_basic_info {
        var count: natural_t = Usage.machTaskBasicInfoCount
        var info: mach_task_basic_info = mach_task_basic_info()
        _ = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        return info
    }

    public static func memory(unit: Unit = .none) -> UInt64? {
        let info = machTaskBasicInfo()
        return info.resident_size / unit.rawValue
    }
}
