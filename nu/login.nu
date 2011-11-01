(load "ZeroKit")

(function cocoa-label (frame)
    (((NSTextField alloc) initWithFrame: frame) set: (bezeled: 0 editable: 0 alignment: NSRightTextAlignment drawsBackground: 0)))

(function cocoa-text-field (frame)
    (((NSTextField alloc) initWithFrame: frame) set: (bezeled: 1 editable: 1  drawsBackground: 1)))

(function cocoa-secure-text-field (frame)
    (((NSSecureTextField alloc) initWithFrame: frame) set: (bezeled: 1 editable: 1 drawsBackground: 1)))

(function cocoa-button (frame)
    (((NSButton alloc) initWithFrame: frame) set: (bezelStyle: NSRoundedBezelStyle)))

(class DracoLoginWindowController is NSObject
    (- (id) init is
        (super init)
        (let (w ((NSWindow alloc) initWithContentRect: '(0 0 318 130)
                                            styleMask: (+ NSTitledWindowMask NSClosableWindowMask NSMiniaturizableWindowMask)
                                              backing: NSBackingStoreBuffered
                                                defer: 0))
            (w set: (title:"Dragon Go Server"))
            (let (view ((NSView alloc) initWithFrame: (w frame)))
                (let (label (cocoa-label '(37 91 86 17)))
                    (label setStringValue: "Username:")
                    (view addSubview: label))
                (let (textField (cocoa-text-field '(128 88 150 22)))
                    (set @usernameTextField textField)
                    (view addSubview: textField))
                (let (label (cocoa-label '(37 59 86 17)))
                    (label setStringValue: "Password:")
                    (label setAction: "logIn:")
                    (view addSubview: label))
                (let (textField (cocoa-secure-text-field '(128 56 150 22)))
                    (set @passwordTextField textField)
                    (view addSubview: textField))
                (let (button (cocoa-button '(202 12 82 32)))
                    (button set: (title: "Log In" action: "logIn:"))
                    (view addSubview: button))
                (w setContentView: view))
                (w center)
                (set @window w))
         self)

    (- (void) logIn: (id)sender is
        (puts "#{(usernameTextField stringValue)} is logging in with password #{(passwordTextField stringValue)}")))
