(load "Growl")
(load "ZeroKit")

(class MyGrowlDelegate is NSObject
    (ivar (id) registrationDictionary)

    (- (id) registrationDictionaryForGrowl is
        (unless @registrationDictionary
            (set @registrationDictionary
                (NSMutableDictionary dictionaryWithList:
                    (list "AllNotifications" (NSArray arrayWithObject: "Draco")
                        "DefaultNotifications" (NSArray arrayWithObject: 0)))))
        @registrationDictionary)

    (- (id) applicationNameForGrowl is "Draco")

    (- (id) applicationIconDataForGrowl is
        ((ZeroKitUtilities imageFromResource: "Draco"
                                    inBundle: (ZeroKitUtilities applicationBundle)) TIFFRepresentation))

    (- (void) growlIsReady is (puts "Growl: ready"))

    (- (void) growlNotificationWasClicked: (id) clickContext is
        (set statusURL (NSURL URLWithString: "http://www.dragongoserver.net/status.php"))
        ((NSWorkspace sharedWorkspace) openURL: statusURL))

    (- (void) growlNotificationTimedOut: (id) clickContext is
        (puts "Growl: notification '#{clickContext}' timed out.")))

(GrowlApplicationBridge setGrowlDelegate: (set $growlDelegate ((MyGrowlDelegate alloc) init)))

(function growl (message)
    (GrowlApplicationBridge notifyWithTitle: "Draco"
                                description: (message stringValue)
                           notificationName: "Draco"
                                   iconData: nil
                                   priority: 0
                                   isSticky: NO
                               clickContext: (message stringValue)))
