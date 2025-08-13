import Foundation
import CoreBluetooth
import MultipeerConnectivity

class DecentralizedMobileAppTracker {
    // MARK: - Properties
    let serviceType = "yf9i-decentral-tracker"
    let peerId = MCPeerID(displayName: UIDevice.current.name)
    let serviceBrowser: MCNearbyServiceBrowser
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let bluetoothManager: CBCentralManager
    var discoveredPeers: [MCPeerID] = []
    var trackedData: [String: Any] = [:]

    // MARK: - Initialization
    init() {
        serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        bluetoothManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MARK: - Functions
    func startTracking() {
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }

    func stopTracking() {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }

    func trackData(_ data: [String: Any]) {
        trackedData = data
        sendTrackedDataToPeers()
    }

    func sendTrackedDataToPeers() {
        for peer in discoveredPeers {
            if let data = try? JSONEncoder().encode(trackedData) {
                do {
                    try serviceAdvertiser.invite(peer, to: serviceAdvertiser.session, withContext: data, timeout: 10)
                } catch {
                    print("Error inviting peer: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension DecentralizedMobileAppTracker: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        discoveredPeers.append(peerID)
        print("Found peer: \(peerID.displayName)")
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = discoveredPeers.firstIndex(of: peerID) {
            discoveredPeers.remove(at: index)
        }
        print("Lost peer: \(peerID.displayName)")
    }
}

extension DecentralizedMobileAppTracker: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Received invitation from peer: \(peerID.displayName)")
        // Handle invitation and establish MCSession
    }
}

extension DecentralizedMobileAppTracker: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("Bluetooth state unknown")
        case .resetting:
            print("Bluetooth resetting")
        case .unsupported:
            print("Bluetooth unsupported")
        case .unauthorized:
            print("Bluetooth unauthorized")
        case .poweredOff:
            print("Bluetooth powered off")
        case .poweredOn:
            print("Bluetooth powered on")
        @unknown default:
            print("Bluetooth unknown state")
        }
    }
}