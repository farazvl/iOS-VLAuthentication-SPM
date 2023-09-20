//
//  UIDeviceExtension.swift
//  VLAuthentication
//
//  Created by Gaurav Vig on 04/01/23.
//

import UIKit

extension UIDevice {
    /**
     Returns device ip address. Nil if connected via celluar.
     */
    func getIPAddress() -> String? {
        var address: String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        var ipAddresses:[String:[String]] = [:]
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        address = String(cString: hostname)
                        if let address {
                            if addr.sa_family == UInt8(AF_INET) {
                                var ip4AddrArr = ipAddresses["ipv4"] ?? []
                                ip4AddrArr.append(address)
                                ipAddresses["ipv4"] = ip4AddrArr
                            }
                            else {
                                var ip6AddrArr = ipAddresses["ipv6"] ?? []
                                ip6AddrArr.append(address)
                                ipAddresses["ipv6"] = ip6AddrArr
                            }
                        }
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        if let ip4AddrArr = ipAddresses["ipv4"], ip4AddrArr.count > 0 {
            var updatedAddress:String = ip4AddrArr.last ?? ""
            ip4AddrArr.forEach { ipaddress in
                if !ipaddress.contains("192.168") {
                    updatedAddress = ipaddress
                }
            }
//            print("address final >>>> \(lastElement)")
            return updatedAddress
        }
        else if let ip6AddrArr = ipAddresses["ipv6"], let lastElement = ip6AddrArr.last {
//            print("address final >>>> \(lastElement)")
            return lastElement
        }
//        print("address final >>>> \(address)")
        return address
    }
}
