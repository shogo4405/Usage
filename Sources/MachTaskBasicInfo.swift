import Foundation

public struct MachTaskBasicInfo {
    static let count:natural_t = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

    public let policy:Int32
    public let residentSize:UInt64
    public let residentSizeMax:UInt64
    public let suspendCount:Int32
    public let systemTime:time_value_t
    public let userTime:time_value_t
    public let virtualSize:UInt64

    public static func current() -> MachTaskBasicInfo? {
        var count:natural_t = MachTaskBasicInfo.count
        var info:mach_task_basic_info = mach_task_basic_info()
        let result:kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard result == KERN_SUCCESS else {
            return nil
        }
        return MachTaskBasicInfo(
            policy: info.policy,
            residentSize: info.resident_size,
            residentSizeMax: info.resident_size_max,
            suspendCount: info.suspend_count,
            systemTime: info.system_time,
            userTime: info.user_time,
            virtualSize: info.virtual_size
        )
    }
}
