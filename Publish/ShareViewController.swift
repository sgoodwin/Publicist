//
//  ShareViewController.swift
//  Publish
//
//  Created by Samuel Goodwin on 5/7/19.
//  Copyright © 2019 Roundwall Software. All rights reserved.
//

import Cocoa
import BlogEngine

struct Validity: Codable {
    let valid: Bool
    let arbitrary: String
}

class ShareViewController: NSViewController {
    @IBOutlet var textView: NSTextView!
    @IBOutlet var sendButton: NSButton!
    
    @IBOutlet var subscriptionOverlay: NSView!

    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    var draft: Draft?
    
    @objc var extensionItems: [NSExtensionItem]!
    
    func checkAttachments() {
//        let raw = """
//SUBQUERY (extensionItems, $extensionItem,
//SUBQUERY ($extensionItem.attachments, $attachment,
//ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.plain-text" ||
//ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "net.daringfireball.markdown"
//).@count == $extensionItem.attachments.@count
//).@count > 0
//"""        
        extensionItems = self.extensionContext?.inputItems as? [NSExtensionItem]
        print(extensionItems?.compactMap({ (item) -> String? in
            return item.attachments?.flatMap({ (attachment) -> [String] in
                return attachment.registeredTypeIdentifiers
            }).joined(separator: ", ")
        }) as Any)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAttachments()
        
        sendButton.isEnabled = false
        subscriptionOverlay.isHidden = isSubscriptionValid()
        
        let extensionItems = self.extensionContext!.inputItems as! [NSExtensionItem]
        let extensionItem = extensionItems[0]
        guard let attachment = extensionItem.attachments?.first else {
            return
        }
        
        func loadWithIdentifier(_ identifier: String) {
            let _ = attachment.loadFileRepresentation(forTypeIdentifier: identifier) { (fileURL, error) in
                if let error = error {
                    print("Error loading file representation: \(String(describing: error))")
                    return
                }
                
                if let fileURL = fileURL, let extractor = PostExtractor(fileURL as NSURL) {
                    self.draft = Draft(title: extractor.title, markdown: extractor.contents, tags: extractor.tags?.map({ TagObject(name: $0) }) ?? [], status: .published, published_at: extractor.publish_date ?? Date())
                    self.sendButton.isEnabled = self.isSubscriptionValid()
                }
            }
        }
        
        if attachment.hasItemConformingToTypeIdentifier("net.daringfireball.markdown") {
            loadWithIdentifier("net.daringfireball.markdown")
        } else if attachment.hasItemConformingToTypeIdentifier("public.text") {
            loadWithIdentifier("public.text")
        }
    }

    @IBAction func openMainApp(_ sender: AnyObject?) {
        let config = NSWorkspace.OpenConfiguration()
        config.createsNewApplicationInstance = false
        NSWorkspace.shared.openApplication(at: URL(string: "publicist://")!, configuration: config, completionHandler: nil)
        extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        guard let draft = draft else {
            return
        }
        
        let accounts = try! viewContext.fetch(Account.fetchRequest() as NSFetchRequest<Account>)
        try! engine.post(draft, toAccount: accounts[0].objectID)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath as Any)
        print(engine.progress)
        
        if engine.progress.isFinished {
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
    
    lazy var engine: BlogEngine = {
        let engine = BlogEngine(context: self.viewContext)
        engine.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
        return engine
    }()

    @objc var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: CustomPersistentContainer = {
        let container = CustomPersistentContainer.blogEngineContainer(group: "SYSB7DM9AH.Publisher")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    private func isSubscriptionValid() -> Bool {        
        let manager = FileManager.default
        let url = manager.containerURL(forSecurityApplicationGroupIdentifier: "SYSB7DM9AH.Publisher")!.appendingPathComponent("validity")
        let decoder = PropertyListDecoder()
        
        do {
            let data = try Data(contentsOf: url)
            let validity = try decoder.decode(Validity.self, from: data)
            return validity.valid == true && validity.arbitrary == "pooppooppoop"
        } catch {
            return false
        }
    }
}
