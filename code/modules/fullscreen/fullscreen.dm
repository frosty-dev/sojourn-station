/client/verb/ToggleFullscreen()
    set name = "Toggle Fullscreen"
    set category = "OOC"

    if(prefs.fullscreen)
        winset(src, "mainwindow", "is-maximized=false;can-resize=false;titlebar=false;menu=\"\"")
        winset(src, "mainwindow", "is-maximized=true")
        prefs.fullscreen = FALSE
    else
        winset(src, "mainwindow", "is-maximized=false;can-resize=true;titlebar=true;menu=menu")
        winset(src, "mainwindow", "is-maximized=true")
        prefs.fullscreen = TRUE

    prefs.save_preferences()

    addtimer(CALLBACK(src,.verb/fit_viewport,10))
