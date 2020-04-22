import
  x11/x,
  x11/xlib,
  nimdowpkg/event/xeventmanager,
  nimdowpkg/config/config,
  nimdowpkg/windowmanger as windowmanager

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

  windowmanager.setupActions()
  config.populateConfigTable(display)
  eventManager = newXEventManager()
  config.hookConfig(eventManager)
  eventManager.startEventListenerLoop(display)
