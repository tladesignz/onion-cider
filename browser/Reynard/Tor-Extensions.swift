//
//  Tor-Extensions.swift
//  Reynard
//
//  Created by Benjamin Erhart on 11.11.26.
//

import Foundation
import os
import GeckoView
import Network
internal import TorManager_iOS_UI
internal import TorManager_iOS
internal import TorManager_Shared
internal import IPtProxyUI_Shared
internal import TorCore
internal import OrbotKit


extension SceneDelegate: StartTorViewControllerDelegate {

    var startVc: StartTorViewController {
        let startVc = StartTorViewController()
        startVc.torManager = TorManager.shared
        startVc.autoConf = !Settings.firstRunDone
        startVc.smartConnect = true
        startVc.delegate = self

        return startVc
    }


    func started() {
        Settings.firstRunDone = true

        let log = Logger(subsystem: Bundle.main.bundleIdentifier!,
                         category: String(describing: type(of: self)))

        log.info("TorConf=\(TorManager.shared.torConf?.compile().description ?? "(nil)")")

        if let port = TorManager.shared.torSocks5Port?.rawValue {
            log.info("Setting Gecko SOCKS5 proxy to port \(port)")

            GeckoRuntime.setDefaultPrefs([
                "network.proxy.type": 1, // 1 = Manual proxy configuration
                "network.proxy.socks": TorManager.shared.torSocks5Host ?? "127.0.0.1", // Tor's default loopback address
                "network.proxy.socks_port": port,
                "network.proxy.socks_version": 5,
                "network.proxy.socks_remote_dns": true
            ])
        }
        else {
            log.error("No port available!")
        }

        let browserViewController = BrowserViewController()
        browserViewController.sessionManager.setApplicationForeground(window?.windowScene?.activationState != .background)

        window?.rootViewController = browserViewController
    }
}

extension TorManager {

    static let shared = TorManager(
        directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("tor", isDirectory: true),
        geoipFile: Bundle.main.url(forResource: "geoip", withExtension: nil),
        geoip6File: Bundle.main.url(forResource: "geoip6", withExtension: nil))
}

extension Settings {

    class var firstRunDone: Bool {
        get {
            defaults?.bool(forKey: "firstRunDone") ?? false
        }
        set {
            defaults?.set(newValue, forKey: "firstRunDone")
        }
    }
}

extension SettingsViewController: BridgesConfDelegate {

    var transport: Transport {
        get {
            Settings.transport
        }
        set {
            Settings.transport = newValue
        }
    }

    var customBridges: [String]? {
        get {
            Settings.customBridges
        }
        set {
            Settings.customBridges = newValue
        }
    }

    var countryCode: String? {
        get {
            Settings.countryCode
        }
        set {
            Settings.countryCode = newValue
        }
    }

    func save() {
        Task {
            do {
                try await TorManager.shared.reconfigureBridges()
            }
            catch {
                Logger(subsystem: Bundle.main.displayName!, category: String(describing: type(of: self)))
                    .error("Could not reconfigure bridges: \(error)")
            }
        }
    }
}
