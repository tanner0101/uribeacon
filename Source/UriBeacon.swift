import GoogleUriBeacon
import UIKit

public protocol DiscoveryDelegate {
    func scanner(scanner: Scanner, discoveredUri: Uri)
    func scanner(scanner: Scanner, lostUri: Uri)
}

func log(message: String) {
    println("[UriBeacon] \(message)")
}

public class Uri: NSObject {

    //public methods
    public init(uriBeacon: UBUriBeacon) {
        self.uri = "\(uriBeacon.URI)"
    }
    
    public var uri: String
    public var title = ""
    public var detail = ""
    
    //webview to receive metadata
    var metadataReceived: (()->())?
    var metadataWebview: UIWebView?
    
    public func getMetadata(done: ()->()) {
        
        self.title = self.uri
        self.detail = "Tap to open"
        
        Uri.getMetadata(self.uri, done: { (title, detail) -> () in
            if let title = title {
                self.title = title
            }
            if let detail = detail {
                self.detail = detail
            }
            done()
        })        
    }
    
    public class func getMetadata(uri: String, done: (title: String?, detail: String?) -> ()) {
        if let url = NSURL(string: "http://narwhal.mtag.io/v1/metadata?url=\(uri)") {
            let request = NSMutableURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { response, data, error in
                
                var title: String?
                var detail: String?
                
                if data != nil {
                    var json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                    
                    
                    if let titleString = json.objectForKey("title") as? String {
                        if titleString != "" {
                            title = titleString
                        }
                    }
                    if let detailString = json.objectForKey("description") as? String {
                        if detailString != "" {
                            detail = detailString
                        }
                    }
                }
                
                done(title: title, detail: detail)
                
            })
        } else {
            done(title: nil, detail: nil)
        }
    }
    
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
    public var uris = [Uri]()
    
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
                    log("Lost Uri: \(knownUri.uri)")
                    
                    self.uris.removeAtIndex( index )
                    self.delegate.scanner(self, lostUri: knownUri)
                    
                }
                
            }

            //Add any new beacons
            for discoveredBeacon in self.uriBeaconScanner.beacons() {
                if let discoveredBeacon = discoveredBeacon as? UBUriBeacon {
                    let uri = Uri(uriBeacon: discoveredBeacon)
                    
                    var foundDiscoveredInKnown = false
                    for knownUri in self.uris {
                        if knownUri.matchesBeacon(discoveredBeacon) {
                            foundDiscoveredInKnown = true
                        }
                    }
                    
                    if !foundDiscoveredInKnown {
                        log("Discovered Uri: \(uri.uri)")
                        
                        self.uris.append( uri )
                        uri.getMetadata({
                            log("Metadata received")
                            self.delegate.scanner(self, discoveredUri: uri)
                        })
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