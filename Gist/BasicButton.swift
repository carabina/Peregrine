import Cocoa

class BasicButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.appearance = NSAppearance(named: NSAppearance.Name.aqua)
        self.wantsLayer = true
        self.layer?.masksToBounds = true
        self.layer?.backgroundColor = .clear

        setupButton()
    }
    
    func setupButton() {
    }

}
