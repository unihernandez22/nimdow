import
  x11 / [x, xlib],
  hashes,
  area

converter boolToXBool(x: bool): XBool = x.XBool

type
  Client* = ref object of RootObj
    window*: Window
    x*: int
    oldX*: int
    y*: int
    oldY*: int
    width*: uint
    oldWidth*: uint
    height*: uint
    oldHeight*: uint
    borderWidth*: uint
    oldBorderWidth*: uint
    isFullscreen*: bool
    isFloating*: bool
    # Non-resizable
    isFixed*: bool

proc hash*(this: Client): Hash

proc newClient*(window: Window): Client =
  Client(window: window)

proc configure*(this: Client, display: PDisplay) =
  var event: XConfigureEvent
  event.theType = ConfigureNotify
  event.display = display
  event.event = this.window
  event.window = this.window
  event.x = this.x.cint
  event.y = this.y.cint
  event.width = this.width.cint
  event.height = this.height.cint
  event.border_width = this.borderWidth.cint
  event.above = None
  event.override_redirect = false
  discard XSendEvent(display, this.window, false, StructureNotifyMask, cast[PXEvent](event.addr))

proc adjustToState*(this: Client, display: PDisplay) =
  ## Changes the client's location, size, and border based on the client's internal state.
  var windowChanges: XWindowChanges
  windowChanges.x = this.x.cint
  windowChanges.y = this.y.cint
  windowChanges.width = this.width.cint
  windowChanges.height = this.height.cint
  windowChanges.border_width = this.borderWidth.cint
  discard XConfigureWindow(
    display,
    this.window,
    CWX or CWY or CWWidth or CWHeight or CWBorderWidth,
    windowChanges.addr
  )
  this.configure(display)

proc isNormal*(this: Client): bool =
  ## If the client is "normal".
  ## This currently means the client is not fixed.
  not this.isFixed

func find*[T](clients: openArray[T], window: Window): int =
  ## Finds a Client's index by its relative window.
  ## If a client is not found, -1 is returned.
  for i, client in clients:
    if client.window == window:
      return i
  return -1

proc findNextNormal*(clients: openArray[Client], i: int = 0): int =
  ## Finds the next normal client index from index `i` (exclusive), iterating forward.
  ## This search will loop the array.
  for j in countup(i + 1, clients.high):
    if clients[j].isNormal:
      return j
  for j in countup(clients.low, i - 1):
    if clients[j].isNormal:
      return j
  return -1

proc findPreviousNormal*(clients: openArray[Client], i: int = 0): int =
  ## Finds the next normal client index from index `i` (exclusive), iterating backward.
  ## This search will loop the array.
  for j in countdown(i - 1, clients.low):
    if clients[j].isNormal:
      return j
  for j in countdown(clients.high, i + 1):
    if clients[j].isNormal:
      return j
  return -1

proc toArea*(this: Client): Area = (this.x, this.y, this.width, this.height)

proc hash*(this: Client): Hash = !$Hash(this.window) 
