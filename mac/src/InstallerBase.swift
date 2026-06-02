import AppKit
import Foundation
import Carbon

// ── Bereitgestellt von config_ch.swift / config_de.swift ──────────────────────
// var kLayoutName:  String
// var kBundleName:  String
// var kSubtitle:    String
// var kPreserved:   String
// var kMapping:     String
// var kBundleID:    String

// ── Fenster ────────────────────────────────────────────────────────────────────
class InstallerWindowController: NSWindowController, NSWindowDelegate {

    override init(window: NSWindow?) {
        let w = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        w.title = "\(kLayoutName) – Tastaturlayout installieren"
        w.isReleasedWhenClosed = false
        super.init(window: w)
        w.delegate = self
        buildInstallerUI()
        w.center()
    }

    required init?(coder: NSCoder) { fatalError() }

    // ── Haupt-UI ──────────────────────────────────────────────────────────────
    func buildInstallerUI() {
        guard let c = window?.contentView else { return }
        c.subviews.forEach { $0.removeFromSuperview() }

        let titleLabel = makeLabel(kLayoutName, size: 20, bold: true)
        let subtitleLabel = makeLabel(kSubtitle, size: 12, color: .secondaryLabelColor)

        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .bezelBorder

        let textView = NSTextView(frame: .zero)
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = NSColor(named: "controlBackgroundColor") ?? .textBackgroundColor
        textView.font = NSFont.monospacedSystemFont(ofSize: 12.5, weight: .regular)
        textView.string = kMapping
        textView.textContainerInset = NSSize(width: 10, height: 10)
        scrollView.documentView = textView

        let preservedLabel = makeLabel(kPreserved, size: 11.5, color: .secondaryLabelColor, mono: true)

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        let cancelBtn = makeButton("Abbrechen", key: "\u{1b}", action: #selector(cancelAction))
        let installBtn = makeButton("Installieren", key: "\r", action: #selector(installAction), highlighted: true)

        [titleLabel, subtitleLabel, scrollView, preservedLabel, separator, cancelBtn, installBtn].forEach { c.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: c.topAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 22),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 22),

            scrollView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 14),
            scrollView.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 22),
            scrollView.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -22),
            scrollView.heightAnchor.constraint(equalToConstant: 215),

            preservedLabel.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            preservedLabel.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 22),

            separator.topAnchor.constraint(equalTo: preservedLabel.bottomAnchor, constant: 14),
            separator.leadingAnchor.constraint(equalTo: c.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: c.trailingAnchor),

            cancelBtn.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12),
            cancelBtn.trailingAnchor.constraint(equalTo: installBtn.leadingAnchor, constant: -8),
            cancelBtn.bottomAnchor.constraint(equalTo: c.bottomAnchor, constant: -16),

            installBtn.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 12),
            installBtn.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -22),
            installBtn.bottomAnchor.constraint(equalTo: c.bottomAnchor, constant: -16),
        ])
    }

    // ── Aktionen ──────────────────────────────────────────────────────────────
    @objc func cancelAction() { NSApp.terminate(nil) }

    @objc func installAction() {
        let fm   = FileManager.default
        let dest = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Keyboard Layouts")
        let src  = Bundle.main.bundleURL
            .appendingPathComponent("Contents/Resources/\(kKeylayoutFile)")
        let destFile = dest.appendingPathComponent(kKeylayoutFile)

        do {
            try fm.createDirectory(at: dest, withIntermediateDirectories: true)
            if fm.fileExists(atPath: destFile.path) {
                try fm.removeItem(at: destFile)
            }
            try fm.copyItem(at: src, to: destFile)
        } catch {
            let a = NSAlert()
            a.messageText = "Fehler beim Installieren"
            a.informativeText = error.localizedDescription
            a.alertStyle = .critical
            a.addButton(withTitle: "OK")
            a.runModal()
            return
        }

        // Layout sofort registrieren (kein Logout nötig wenn erfolgreich)
        let registered = registerLayout(at: destFile)
        showSuccess(needsLogout: !registered)
    }

    func registerLayout(at url: URL) -> Bool {
        // TISRegisterInputSource teilt dem System den neuen Layout mit
        let cfUrl = url as CFURL
        let status = TISRegisterInputSource(cfUrl)
        return status == noErr
    }

    // ── Erfolgs-Screen ────────────────────────────────────────────────────────
    func showSuccess(needsLogout: Bool = false) {
        guard let c = window?.contentView else { return }
        c.subviews.forEach { $0.removeFromSuperview() }
        window?.title = "\(kLayoutName) – Installiert"
        window?.setContentSize(NSSize(width: 440, height: 310))
        window?.center()

        let check = makeLabel("✓", size: 52, color: .systemGreen)
        let title = makeLabel("\(kLayoutName) wurde installiert.", size: 16, bold: true)

        var stepsText =
            "Nächste Schritte:\n\n" +
            "1.  Systemeinstellungen → Tastatur → Eingabequellen\n" +
            "2.  Auf + klicken und \"\(kLayoutName)\" suchen\n" +
            "3.  Layout hinzufügen und in der Menüleiste aktivieren"
        if needsLogout {
            stepsText += "\n\nFalls das Layout nicht erscheint: Ab- und wieder anmelden."
        }

        let steps = NSTextField(wrappingLabelWithString: stepsText)
        steps.font = NSFont.systemFont(ofSize: 13)
        steps.translatesAutoresizingMaskIntoConstraints = false

        let doneBtn = makeButton("Fertig", key: "\r", action: #selector(cancelAction), highlighted: true)

        [check, title, steps, doneBtn].forEach { c.addSubview($0) }

        NSLayoutConstraint.activate([
            check.topAnchor.constraint(equalTo: c.topAnchor, constant: 30),
            check.centerXAnchor.constraint(equalTo: c.centerXAnchor),

            title.topAnchor.constraint(equalTo: check.bottomAnchor, constant: 8),
            title.centerXAnchor.constraint(equalTo: c.centerXAnchor),

            steps.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 18),
            steps.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 30),
            steps.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -30),

            doneBtn.bottomAnchor.constraint(equalTo: c.bottomAnchor, constant: -18),
            doneBtn.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -22),
        ])
    }

    func windowWillClose(_ notification: Notification) { NSApp.terminate(nil) }

    // ── Hilfsmethoden ─────────────────────────────────────────────────────────
    func makeLabel(_ text: String, size: CGFloat, bold: Bool = false,
                   color: NSColor = .labelColor, mono: Bool = false) -> NSTextField {
        let l = NSTextField(labelWithString: text)
        l.font = mono
            ? NSFont.monospacedSystemFont(ofSize: size, weight: bold ? .bold : .regular)
            : (bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size))
        l.textColor = color
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }

    func makeButton(_ title: String, key: String, action: Selector, highlighted: Bool = false) -> NSButton {
        let b = NSButton(title: title, target: self, action: action)
        b.keyEquivalent = key
        b.bezelStyle = .rounded
        if highlighted { (b.cell as? NSButtonCell)?.setButtonType(.momentaryPushIn) }
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }
}

// ── App Delegate ───────────────────────────────────────────────────────────────
class AppDelegate: NSObject, NSApplicationDelegate {
    var wc: InstallerWindowController?
    func applicationDidFinishLaunching(_ n: Notification) {
        wc = InstallerWindowController(window: nil)
        wc?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
