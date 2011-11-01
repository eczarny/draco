(load "ZeroKit")

(function cocoa-label (frame)
    (((NSTextField alloc) initWithFrame: frame) set: (bezeled: 0 editable: 0 alignment: NSRightTextAlignment drawsBackground: 0)))

(function cocoa-checkbox (frame)
    (((NSButton alloc) initWithFrame: frame) set: (buttonType: 3)))

(class DracoGeneralPreferencePane is NSObject
    (- (void) preferencePaneDidLoad is
        (set @applicationBundle (ZeroKitUtilities applicationBundle))
        (set loginAtLaunchEnabledState 0)
        (let (checkbox (cocoa-checkbox '(182 19 322 18)))
        (checkbox set: (title: "Launch Draco at login" target: self action: "toggleLoginItem:"))
            (set @launchAtLogin checkbox))
        (if ((ZeroKitUtilities isLoginItemEnabledForBundle: @applicationBundle))
            (set loginAtLaunchEnabledState 1))
        (@launchAtLogin setState: loginAtLaunchEnabledState))

    (- (id) name is "General")

    (- (id) icon is
        (ZeroKitUtilities imageFromResource: "General Preferences"
                                   inBundle: @applicationBundle))

    (- (id) toolTip is nil)

    (- (id) view is
        (set view ((NSView alloc) initWithFrame: '(0 0 520 80)))
        (let (label (cocoa-label '(14 43 165 17)))
            (label setStringValue: "Growl:")
            (view addSubview: label))
        (let (checkbox (cocoa-checkbox '(182 42 322 18)))
            (checkbox set: (title: "Enable Growl for notifications" enabled: 0))
            (view addSubview: checkbox))
        (let (label (cocoa-label '(14 20 165 17)))
            (label setStringValue: "Launch Options:")
            (view addSubview: label))
        (view addSubview: @launchAtLogin)
        view)

    (- (void) toggleLoginItem: (id)sender is
        (if (== (@launchAtLogin state) 1)
            (ZeroKitUtilities enableLoginItemForBundle: @applicationBundle)
            (else
                (ZeroKitUtilities disableLoginItemForBundle: @applicationBundle)))))
