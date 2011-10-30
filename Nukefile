;; Nukefile for Draco

(set @application "Draco")
(set @application_identifier "com.divisiblebyzero.Draco")
(set @application_creator_code "ZERO")
(set @application_icon_file "Draco.icns")

(set @nu_files (filelist "^nu/.*nu$"))
(set @xib_files (filelist "^resources/.*\.xib$"))
(set @icon_files (filelist "^resources/.*(\.icns|\.tiff)$"))
(set @resources (filelist "^resources/.*\.plist$"))

(set @info (NSDictionary dictionaryWithList:
    (list
        "LSUIElement" YES)))

(application-tasks)

(task "default" => "application")
