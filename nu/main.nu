(load "Nu:nu")
(load "Nu:cocoa")
(load "ZeroKit")
(load "menu")
(load "growl")
(load "preferences")
(load "login")

(global NSVariableStatusItemLength -1)

(global kRefreshInterval 5)
(global kDGSHostName "http://www.dragongoserver.net")
(global kInsertionIndex 3)
(global kPendingMoveTag 42)
(global kAuthenticationTag 84)

(class DracoGame is NSObject
    (- (id) initWithGame: (id)game is
        (super init)
        (set @game game)
        self)

    (- (id) opponent is (head (tail @game)))

    (- (void) openGame: (id)sender is
        (set statusURL (NSURL URLWithString: "#{kDGSHostName}/game.php?gid=#{(head @game)}"))
        ((NSWorkspace sharedWorkspace) openURL: statusURL)))

(function repeating-timer (delay target selector)
    (NSTimer scheduledTimerWithTimeInterval: delay target: target selector: selector userInfo: nil repeats: YES))

(class DracoApplicationDelegate is NSObject
    (- (id) init is
        (super init)
        (set @timer (repeating-timer (* 60 kRefreshInterval) self "refresh:"))
        self)

    (- (void) applicationWillFinishLaunching: (id)sender is
        (set @statusMenu (create-menu
            '(menu "Draco"
                ("Refresh" action: "refresh:")
                ("Status" action: "openStatus:")
                (separator)
                ("No Pending Moves" tag: kPendingMoveTag)
                (separator)
                ("Preferences..." action: "togglePreferences:")
                (separator)
                ("Log Out" action: "logOut:" tag: kAuthenticationTag)
                ("Quit Draco" target: (NSApplication sharedApplication) action: "terminate:"))))

        (set statusItem (((NSStatusBar systemStatusBar) statusItemWithLength: NSVariableStatusItemLength) retain))

        (statusItem setTitle: "dGs")
        (statusItem setHighlightMode: YES)
        (statusItem setMenu: @statusMenu))

    (- (void) applicationDidFinishLaunching: (id)sender is
        (set notificationCenter (NSNotificationCenter defaultCenter))

        (notificationCenter addObserver: self
                               selector: "menuDidSendAction:"
                                   name: "NSMenuDidSendActionNotification"
                                 object: nil)
        (notificationCenter addObserver: self
                               selector: "userDidLogIn:"
                                   name: "DracoUserDidLogInNotification"
                                 object: nil)
        (notificationCenter addObserver: self
                               selector: "userDidLogOut:"
                                   name: "DracoUserDidLogOutNotification"
                                 object: nil)

        (set @loginController ((DracoLoginWindowController alloc) init))
        (@timer fire))

    (- (void) refresh: (id)sender is
        (set connectionManager (ZeroKitURLConnectionManager sharedManager))
        (set request ((NSURLRequest alloc) initWithURL: (NSURL URLWithString: "#{kDGSHostName}/quick_status.php")))
        (connectionManager spawnConnectionWithURLRequest: request delegate: self))

    (- (void) logOut: (id)sender is
        (set connectionManager (ZeroKitURLConnectionManager sharedManager))
        (set request ((NSURLRequest alloc) initWithURL: (NSURL URLWithString: "#{kDGSHostName}/index.php?logout=t")))
        (connectionManager spawnConnectionWithURLRequest: request delegate: self))

    (- (void) openStatus: (id)sender is
        (set statusURL (NSURL URLWithString: "#{kDGSHostName}/status.php"))
        ((NSWorkspace sharedWorkspace) openURL: statusURL))

    (- (void) togglePreferences: (id)sender is
        ((ZeroKitPreferencesWindowController sharedController) togglePreferencesWindow: sender))

    (- (void) displayLogin: (id)sender is
        ((@loginController window) makeKeyAndOrderFront: self))

    (- (void) request: (id)request didReceiveData: (id)data is
        (if (not (((request URL) absoluteString) contains: "logout"))
            (self clearGamesPendingMoves)
            (try
                (set gamesAwaitingMoves (self gamesAwaitingMovesFromData: data))
                (self processGamesAwaitingMoves: gamesAwaitingMoves)
                (catch (exception)
                    ((NSNotificationCenter defaultCenter) postNotificationName: "DracoUserDidLogOutNotification"
                                                                        object: self)
                    (growl "Draco encountered a problem" exception)))
        (else
            ((NSNotificationCenter defaultCenter) postNotificationName: "DracoUserDidLogOutNotification"
                                                                object: self))))

    (- (void) clearGamesPendingMoves is
        (set items ((@statusMenu itemArray) list))
        (items each:
            (do (item)
                (if (== (item tag) kPendingMoveTag)
                    (@statusMenu removeItem: item)))))

    (- (void) processGamesAwaitingMoves: (id)gamesAwaitingMoves is
        (if (> (gamesAwaitingMoves count) 0)
            (set insertionIndex kInsertionIndex)
            (set numberOfPendingMoves (gamesAwaitingMoves count))
            (gamesAwaitingMoves each:
                (do (game)
                    (set item (create-menu-item `(,("#{(game opponent)} is waiting") target: ,(game) action: "openGame:" tag: kPendingMoveTag)))
                    (@statusMenu insertItem: item atIndex: insertionIndex)
                    (set insertionIndex (+ insertionIndex 1))))
                    (growl "Moves pending"
                        (if (> numberOfPendingMoves 1)
                            ("#{numberOfPendingMoves} games requiring your attention.")
                            (else
                                ("1 game requires your attention."))))
        (else
            (set item (create-menu-item '("No Pending Moves" tag: kPendingMoveTag)))
            (@statusMenu insertItem: item atIndex: kInsertionIndex))))

    (- (id) gamesAwaitingMovesFromData: (id)data is
        (set response ((NSString alloc) initWithBytes: (data bytes) length: (data length) encoding: NSUTF8StringEncoding))
        (set lines ((response lines) list))
        (set gamesAwaitingMoves (NSMutableArray array))
        (lines each:
            (do (line)
                (set game ((line componentsSeparatedByString: ", ") list))
                (cond
                    ((== (head game) "'G'")
                        (gamesAwaitingMoves addObject: (((DracoGame alloc) initWithGame: (tail game)) retain)))
                    ((== (head game) "'M'")
                        (growl "Messages waiting" "There are messages waiting for you."))
                    (t
                        (if (not (line contains: "empty lists"))
                            (throw "Please log in to check for pending moves."))))))
        (gamesAwaitingMoves list))

    (- (void) menuDidSendAction: (id)notification is
        ((NSApplication sharedApplication) activateIgnoringOtherApps: YES))

    (- (void) userDidLogIn: (id)notification is
        (set authenticationMenuItem (@statusMenu itemWithTag: kAuthenticationTag))
        (authenticationMenuItem set: (title: "Log Out" action: "logOut:"))
        (self refresh: self))

    (- (void) userDidLogOut: (id)notification is
        (self clearGamesPendingMoves)
        (set item (create-menu-item '("Not Logged In" tag: kPendingMoveTag)))
        (@statusMenu insertItem: item atIndex: kInsertionIndex)
        (set authenticationMenuItem (@statusMenu itemWithTag: kAuthenticationTag))
        (authenticationMenuItem set: (title: "Log In..." action: "displayLogin:"))))

((NSApplication sharedApplication) setDelegate: (set delegate ((DracoApplicationDelegate alloc) init)))

(NSApplicationMain 0 nil)
