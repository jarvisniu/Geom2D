# Draw circle by dragging out a radius

class Bu.DrawCircleDiameterReactor extends Bu.ReactorBase

  constructor: (@bu) ->
    super()

    mousePos = new Bu.Point
    mousePosDown = new Bu.Point

    isConfirmed = true

    circle = null
    line = null

    # create new circles every time
    @onMouseDown = (ev) =>
      if not isConfirmed
        circle = null
        isConfirmed = yes
      else
        mousePosDown.set ev.offsetX, ev.offsetY
        circle = new Bu.Circle 1, mousePosDown.x, mousePosDown.y
        @bu.scene.addChild circle

        line = new Bu.Line mousePosDown, mousePosDown
        line.stroke '#f44'
        @bu.scene.addChild line
        isConfirmed = no

    # change radius
    @onMouseMove = (ev) ->
      mousePos.set ev.offsetX, ev.offsetY
      if (not isConfirmed) or (ev.buttons == Bu.MOUSE.LEFT and circle?)
        line.setPoint2(mousePos)
        circle.radius = mousePos.distanceTo(mousePosDown) / 2
        circle.center = line.midpoint

    @onMouseUp = ->
      isConfirmed = mousePos.distanceTo(mousePosDown) > Bu.POINT_RENDER_SIZE
