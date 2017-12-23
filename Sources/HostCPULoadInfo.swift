import Foundation

public struct HostCPULoadInfo {
    static let count:natural_t = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
    static let machHost:mach_port_t = mach_host_self()

    public let user:Double
    public let system:Double
    public let idle:Double
    public let nice:Double

    public static func current() -> HostCPULoadInfo? {
        var count:natural_t = HostCPULoadInfo.count
        var info:host_cpu_load_info = host_cpu_load_info()
        let result:kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(machHost, HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return nil
        }
        return HostCPULoadInfo(
            user: Double(info.cpu_ticks.0),
            system: Double(info.cpu_ticks.1),
            idle: Double(info.cpu_ticks.2),
            nice: Double(info.cpu_ticks.3)
        )
    }
}
