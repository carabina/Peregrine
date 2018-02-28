import Cocoa
import OAuth2

class GistViewController: NSViewController {
    
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var loginLabel: NSTextField!
    
    @IBOutlet weak var descriptionField: NSTextField!
    @IBOutlet weak var secretButton: SwitchButton!
    @IBOutlet weak var pasteButton: NSButton!

    @IBOutlet var textField: NSTextView!
    @IBOutlet var background: NSView!
    
    var loader = GitHubLoader()
    
    let OAuthCallback = NSNotification.Name(rawValue: "OAuthCallback")
    var loggedIn = false

    override func viewDidLoad() {
        setupView()
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
    }
    
    func setupView() {
        loginLabel.stringValue = ""
        
        let area = NSTrackingArea.init(rect: loginButton.bounds,
            options: [
                NSTrackingArea.Options.mouseEnteredAndExited,
                NSTrackingArea.Options.activeAlways
            ], owner: self, userInfo: nil)
        loginButton.addTrackingArea(area)
        
        background.layer?.backgroundColor = CGColor.gistGray
    }
    
    override func mouseEntered(with event: NSEvent) {
        loginLabel.stringValue = "Log " + (loggedIn ? "Out" : "In")
    }
    
    override func mouseExited(with event: NSEvent) {
        loginLabel.stringValue = ""
    }
    
    @IBAction func buttonPress(_ sender: NSButton) {
        createGist()
    }
    
    @IBAction func login(_ sender: NSButton?) {
        if self.loggedIn {
            forgetTokens()
            return
        }
        else {
            login()
        }
    }
    
    @IBAction func pasteClipboard(_ sender: Any) {
        textField.string = getClipboard()
    }
    
    func getClipboard() -> String {
        let clipboard = NSPasteboard.general
        guard let content = clipboard.string(forType: .string) else {
            return ""
        }
        return content
    }
    
    func setClipboard(content: String) {
        let clipboard = NSPasteboard.general
        clipboard.clearContents()
        clipboard.setString(content, forType: .string)
    }
    
    func createGist() {
        let content = textField.string
        let filename = "gist"
        let description = descriptionField.stringValue
        let secret = secretButton.state == .on
        loader.postGist(content: content, filename: filename,
            description: description, secret: secret) { dict, error in
            if let _ = error {
                self.label?.stringValue = "Error"
            }
            else if let gistUrl = dict?["html_url"] as? String {
                self.setClipboard(content: gistUrl)
            }
        }
    }
    
    func login() {
        label?.stringValue = "Opening GitHub"
        loginButton?.isEnabled = false
        
        // Configure OAuth2 callback
        loader.oauth2.authConfig.authorizeContext = view.window
        NotificationCenter.default.removeObserver(self, name: OAuthCallback, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRedirect(_:)), name: OAuthCallback, object: nil)
        
        // Request user data
        loader.requestUserdata() { dict, error in
            if let error = error {
                self.label?.stringValue = "Error"
                self.show(error)
            }
            else {
                if let imgURL = dict?["avatar_url"] as? String {
                    if let url = URL(string: imgURL), let data = try? Data(contentsOf: url) {
                        self.loginButton.image = NSImage(data: data)
                    }
                }
                if let username = dict?["name"] as? String {
                    self.label?.stringValue = "\(username)"
                }
                
                self.loggedIn = true
                self.loginButton?.isEnabled = true
                self.label?.isHidden = false
            }
        }
    }
    
    func forgetTokens() {
        self.loggedIn = false

        loader.oauth2.forgetTokens()
        label?.stringValue = "Log In"
        
        loginButton.image = NSImage(named: NSImage.Name("GitHub-White"))
        label?.isHidden = false
    }
    
    // MARK: - Authorization
    @objc func handleRedirect(_ notification: Notification) {
        if let url = notification.object as? URL {
            label?.stringValue = "Loading"
            do {
                try loader.oauth2.handleRedirectURL(url)
            }
            catch let error {
                show(error)
            }
        }
        else {
            show(NSError(domain: NSCocoaErrorDomain, code: 0, userInfo:
                [NSLocalizedDescriptionKey: "Invalid URL"]
            ))
        }
    }
    
    // MARK: - Error Handling
    
    // Create error to display
    func show(_ error: Error) {
        if let error = error as? OAuth2Error {
            let err = NSError(domain: "OAuth2Error", code: 0, userInfo:
                [NSLocalizedDescriptionKey: error.description]
            )
            display(err)
        }
        else {
            display(error as NSError)
        }
    }
    
    // Alert or log the given NSError
    func display(_ error: NSError) {
        if let window = self.view.window {
            NSAlert(error: error).beginSheetModal(for: window, completionHandler: nil)
        }
        else {
            NSLog("Error authorizing: \(error.description)")
        }
    }
}

extension CGColor {
    static let gistGray = CGColor.init(
        red: 36.0 / 255.0, green: 41.0 / 255.0, blue: 46.0 / 255.0,
        alpha: 1.0
    )
}