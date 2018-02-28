import Cocoa

class SplitViewController: NSSplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func splitView(_ splitView: NSSplitView,
                   effectiveRect proposedEffectiveRect: NSRect,
                   forDrawnRect drawnRect: NSRect,
                   ofDividerAt dividerIndex: Int) -> NSRect {
        return NSRect(x: 0, y: 0, width: 0, height: 0)
    }

    override func splitView(_ splitView: NSSplitView, shouldHideDividerAt dividerIndex: Int) -> Bool {
        return true
    }
}

extension SplitViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> NSViewController {
        //todo remove magic names
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("SplitViewController")
        
        return storyboard.instantiateController(withIdentifier: identifier) as! NSViewController
    }
}
