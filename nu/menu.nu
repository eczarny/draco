;; @file       menu.nu
;; @discussion Taken largely from menu.nu provided by Nu itself. This version
;;             makes it easier to make arbitrary menus, not just main menus
;;             for applications.
;;
;; @copyright Copyright (c) 2007 Tim Burks, Neon Design Technology, Inc.
;;
;;   Licensed under the Apache License, Version 2.0 (the "License"); you may not
;;   use this file except in compliance with the License. You may obtain a copy
;;   of the License at
;;
;;       http://www.apache.org/licenses/LICENSE-2.0
;;
;;   Unless required by applicable law or agreed to in writing, software
;;   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
;;   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
;;   License for the specific language governing permissions and limitations
;;   under the License.

(function create-menu (menu-description)
    (cond
        ((eq (head menu-description) 'menu)
            (set menu ((NSMenu alloc) initWithTitle: (eval (head (tail menu-description)))))
            (set rest (tail (tail menu-description)))
            (if rest
                (rest each:
                    (do (item)
                        (menu addItem: (create-menu item)))))
            menu)
        ((eq (head menu-description) 'separator)
            (NSMenuItem separatorItem))
        (t
            (create-menu-item menu-description))))

(function create-menu-item (menu-item-description)
    (let ((item ((NSMenuItem alloc) initWithTitle: (eval (head menu-item-description)) action: nil keyEquivalent: ""))
          (rest (tail menu-item-description)))
    (if rest
        (rest eachPair:
            (do (key value)
            (cond ((eq key 'target:)        (item setTarget: (eval value)))
                  ((eq key 'action:)        (item setAction: (eval value)))
                  ((eq key 'keyEquivalent:) (item setKeyEquivalent: (eval value)))
                  ((eq key 'keyModifier:)   (item setKeyEquivalentModifierMask: (eval value)))
                  ((eq key 'tag:)           (item setTag: (eval value)))))))
    item))
