import
  x11 / [x, xlib],
  nimdowpkg /
    [ 
      event / xeventmanager,
      config / config
    ]

var
  display: PDisplay
  rootWindow: TWindow
  windowAttribs: TXSetWindowAttributes
  eventManager: XEventManager

proc initXWindowInfo(): PDisplay =
  let tempDisplay = XOpenDisplay(nil)
  if tempDisplay == nil:
    quit "Failed to open display"
  return tempDisplay

when isMainModule:
  display = initXWindowInfo()
  rootWindow = DefaultRootWindow(display)

  # Listen for events defined by eventMask.
  # See https://tronche.com/gui/x/xlib/events/processing-overview.html#SubstructureRedirectMask
  # Events bubble up the hierarchy to the root window.
  windowAttribs.eventMask =
    SubstructureRedirectMask or
    SubstructureNotifyMask or
    ButtonPressMask or PointerMotionMask or
    EnterWindowMask or
    LeaveWindowMask or
    StructureNotifyMask or
    PropertyChangeMask or
    KeyPressMask or
    KeyReleaseMask

  # Listen for events on the root window
  discard XChangeWindowAttributes(
    display,
    rootWindow,
    CWEventMask or CWCursor,
    addr(windowAttribs)
  )

  eventManager = newXEventManager()
  display.populateConfigTable()
  eventManager.hookConfig()
  eventManager.startEventListenerLoop(display)

