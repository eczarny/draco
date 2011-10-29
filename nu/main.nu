(load "Nu:nu")
(load "Nu:cocoa")
(load "ZeroKit")
(load "menu")
(load "growl")

(global NSVariableStatusItemLength -1)

(global kRefreshInterval 5)
(global kInsertionIndex  2)
(global kPendingMoveTag 42)

(class ApplicationDelegate is NSObject
    (- (void) applicationWillFinishLaunching: (id)sender is
        (set @statusMenu (create-menu
            '(menu "Draco"
                ("Refresh" action: "refresh:")
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
        (set @timer (NSTimer scheduledTimerWithTimeInterval: (* 60 kRefreshInterval) target: self selector: "refresh:" userInfo: nil repeats: YES))
	(@timer fire))

    (- (void) refresh: (id) sender is
        (set connectionManager (ZeroKitURLConnectionManager sharedManager))
        (set request ((NSURLRequest alloc) initWithURL: (NSURL URLWithString: "http://www.dragongoserver.net/quick_status.php")))
        (connectionManager spawnConnectionWithURLRequest: request delegate: self))

    (- (void) request: (id)request didReceiveData: (id)data is
        (self clearGamesPendingMoves)
        (set gamesAwaitingMoves (self gamesAwaitingMovesFromData: data))
        (if (> (gamesAwaitingMoves count) 0)
            (set insertionIndex kInsertionIndex)
            (gamesAwaitingMoves each:
                (do (game)
		    (set item ((NSMenuItem alloc) initWithTitle: "Game with #{(head (tail game))}" action: nil keyEquivalent: ""))
		    (item setTag: kPendingMoveTag)
		    (@statusMenu insertItem: item atIndex: insertionIndex)
		    (set insertionIndex (+ insertionIndex 1))
		    (growl "Move pending" "Your move with #{(head (tail game))}" (head game))
		    (NSThread sleepForTimeInterval: 1)))
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
