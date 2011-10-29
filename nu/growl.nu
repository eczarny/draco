(load "Growl")
(load "ZeroKit")

(global kNotificationName "Draco")

(class DracoGrowlDelegate is NSObject
    (ivar (id) registrationDictionary)

    (- (id) registrationDictionaryForGrowl is
        (unless @registrationDictionary
            (set @registrationDictionary
                (NSMutableDictionary dictionaryWithList:
                    (list "AllNotifications"     (NSArray arrayWithObject: kNotificationName)
                          "DefaultNotifications" (NSArray arrayWithObject: kNotificationName)))))
        @registrationDictionary)

    (- (id) applicationNameForGrowl is "Draco")

    (- (id) applicationIconDataForGrowl is
        ((ZeroKitUtilities imageFromResource: "Draco"
                                    inBundle: (ZeroKitUtilities applicationBundle)) TIFFRepresentation))

    (- (void) growlNotificationWasClicked: (id)clickContext is
        (set gameURL (NSURL URLWithString: "#{kDGSHostName}/game.php?gid=#{clickContext}"))
        ((NSWorkspace sharedWorkspace) openURL: gameURL)))

(GrowlApplicationBridge setGrowlDelegate: (set $growlDelegate ((DracoGrowlDelegate alloc) init)))

(function growl (title message clickContext)
    (GrowlApplicationBridge notifyWithTitle: title
                                description: message
                           notificationName: kNotificationName
                                   iconData: nil
                                   priority: 0
                                   isSticky: NO
                               clickContext: clickContext))
