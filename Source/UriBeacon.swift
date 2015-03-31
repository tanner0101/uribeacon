import GoogleUriBeacon

public protocol DiscoveryDelegate {
    func scanner(scanner: Scanner, discoveredURI: URI)
    func scanner(scanner: Scanner, lostURI: URI)
}

public class URI {

    //public methods
    public init(uriBeacon: UBUriBeacon) {
        self.uri = "\(uriBeacon.URI)"
    }
    
    public var uri: String
    
    //private methods
    var importance: Int = 0
    func matchesBeacon(uriBeacon: UBUriBeacon) -> Bool {
        return self.uri == "\(uriBeacon.URI)"
    }
    
}

public class Scanner {
    
    var delegate: DiscoveryDelegate
    public init(delegate: DiscoveryDelegate) {
        self.delegate = delegate
    }
    
    var uriBeaconScanner = UBUriBeaconScanner()
    public var uris = [URI]()
    
    public func startScanning() {
        self.uriBeaconScanner.startScanningWithUpdateBlock({
            
            //Remove any missing beacons
            for (index, knownUri) in enumerate(self.uris) {
                
                var foundKnownInDiscovered = false
                for discoveredBeacon in self.uriBeaconScanner.beacons() {
                    if let discoveredBeacon = discoveredBeacon as? UBUriBeacon {
                        
                        if knownUri.matchesBeacon(discoveredBeacon) {
                            foundKnownInDiscovered = true
                        }
                        
                    }
                }
                
                if !foundKnownInDiscovered {
                    self.uris.removeAtIndex( index )
                    self.delegate.scanner(self, lostURI: knownUri)
                    print("[UriBeacon] Lost URI: ")
                    println(knownUri.uri)
                    
                }
                
            }

            //Add any new beacons
            for discoveredBeacon in self.uriBeaconScanner.beacons() {
                if let discoveredBeacon = discoveredBeacon as? UBUriBeacon {
                    let uri = URI(uriBeacon: discoveredBeacon)
                    
                    var foundDiscoveredInKnown = false
                    for knownUri in self.uris {
                        if knownUri.matchesBeacon(discoveredBeacon) {
                            foundDiscoveredInKnown = true
                        }
                    }
                    
                    if !foundDiscoveredInKnown {
                        self.uris.append( uri )
                        self.delegate.scanner(self, discoveredURI: uri)
                        print("[UriBeacon] Discovered URI: ")
                        println(uri.uri)
                    }
                    
                }
            }
            
            //Update RSSIs on known URIs
            for discoveredBeacon in self.uriBeaconScanner.beacons() {
                if let discoveredBeacon = discoveredBeacon as? UBUriBeacon {
                    for knownUri in self.uris {
                        if knownUri.matchesBeacon(discoveredBeacon) {
                            knownUri.importance = discoveredBeacon.RSSI
                        }
                    }
                }
            }
            
            //Sort beacons by URIs
            self.uris.sort({ $0.importance > $1.importance })
            
        })
    }
}