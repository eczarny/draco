(load "Nu:nu")
(load "Nu:cocoa")
(load "ZeroKit")
(load "menu")
(load "growl")

(global NSVariableStatusItemLength -1)

(global kRefreshInterval 5)
(global kDGSHostName "http://www.dragongoserver.net")
(global kInsertionIndex 3)
(global kPendingMoveTag 42)

(class ApplicationDelegate is NSObject
    (- (void) applicationWillFinishLaunching: (id)sender is
        (set @statusMenu (create-menu
            '(menu "Draco"
                ("Refresh" action: "refresh:")
		("Active Games" action: "openActiveGames:")
                (separator)
		("No Pending Moves" tag: kPendingMoveTag)
		(separator)
                ("Preferences...")
                (separator)
                ("Quit Draco" target: (NSApplication sharedApplication) action: "terminate:"))))
        (set statusItem (((NSStatusBar systemStatusBar) statusItemWithLength: NSVariableStatusItemLength) retain))
        (statusItem setTitle: "dGs")
        (statusItem setHighlightMode: YES)
        (statusItem setMenu: @statusMenu))

    (- (void) applicationDidFinishLaunching: (id)sender is
        (set @timer (NSTimer scheduledTimerWithTimeInterval: (* 60 kRefreshInterval)
						     target: self
						   selector: "refresh:"
						   userInfo: nil
						    repeats: YES))
	(@timer fire))

    (- (void) refresh: (id)sender is
        (set connectionManager (ZeroKitURLConnectionManager sharedManager))
        (set request ((NSURLRequest alloc) initWithURL: (NSURL URLWithString: "#{kDGSHostName}/quick_status.php")))
        (connectionManager spawnConnectionWithURLRequest: request delegate: self))

    (- (void) openActiveGames: (id)sender is
        (set statusURL (NSURL URLWithString: "#{kDGSHostName}/status.php"))
        ((NSWorkspace sharedWorkspace) openURL: statusURL))

    (- (void) request: (id)request didReceiveData: (id)data is
        (self clearGamesPendingMoves)
        (set gamesAwaitingMoves (self gamesAwaitingMovesFromData: data))
        (if (> (gamesAwaitingMoves count) 0)
            (set insertionIndex kInsertionIndex)
	    (set numberOfPendingMoves (gamesAwaitingMoves count))
            (gamesAwaitingMoves each:
                (do (game)
		    (set item ((NSMenuItem alloc) initWithTitle: "#{(head (tail game))} is waiting" action: nil keyEquivalent: ""))
		    (item setTag: kPendingMoveTag)
		    (@statusMenu insertItem: item atIndex: insertionIndex)
		    (set insertionIndex (+ insertionIndex 1))))
	    (growl "Moves pending"
		   (if (> numberOfPendingMoves 1)
		       ("#{numberOfPendingMoves} games requiring your attention.")
		       (else
			   ("1 game requires your attention."))))
	    (else
		(set item ((NSMenuItem alloc) initWithTitle: "No Pending Moves" action: nil keyEquivalent: ""))
		(item setTag: kPendingMoveTag)
		(@statusMenu insertItem: item atIndex: kInsertionIndex))))

    (- (void) clearGamesPendingMoves is
        (set items ((@statusMenu itemArray) list))
	(items each:
            (do (item)
                (if (== (item tag) kPendingMoveTag)
		    (@statusMenu removeItem: item)))))

    (- (id) gamesAwaitingMovesFromData: (id)data is
        (set response ((NSString alloc) initWithBytes: (data bytes) length: (data length) encoding: NSUTF8StringEncoding))
        (set lines ((response componentsSeparatedByString: "\n") list))
	(set gamesAwaitingMoves (NSMutableArray array))
        (lines each:
            (do (line)
	        (set game ((line componentsSeparatedByString: ", ") list))
		(if (== (head game) "'G'")
		    (gamesAwaitingMoves addObject: (tail game)))))
        gamesAwaitingMoves))

((NSApplication sharedApplication) setDelegate: (set delegate ((ApplicationDelegate alloc) init)))

(NSApplicationMain 0 nil)
