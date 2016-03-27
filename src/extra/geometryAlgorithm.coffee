# Geometry Algorithm Gather

Bu.geometryAlgorithm = G =

	inject: ->
		@injectInto [
			'point'
			'line'
			'circle'
			'triangle'
			'rectangle'
			'fan'
			'bow'
			'polygon'
			'polyline'
		]

	injectInto: (shapes) ->
		shapes = [shapes] if typeof shapes == 'string'

		if 'point' in shapes
			Bu.Point::inCircle = (circle) ->
				G.pointInCircle @, circle
			Bu.Point::distanceTo = (point) ->
				G.distanceFromPointToPoint @, point
			Bu.Point::isNear = (target, limit = Bu.DEFAULT_NEAR_DIST) ->
				switch target.type
					when 'Point'
						G.pointNearPoint @, target, limit
					when 'Line'
						G.pointNearLine @, target, limit
					when 'Polyline'
						G.pointNearPolyline @, target, limit
			Bu.Point.interpolate = G.interpolateBetweenTwoPoints

		if 'line' in shapes
			Bu.Line::distanceTo = (point) ->
				G.distanceFromPointToLine point, @
			Bu.Line::isTwoPointsSameSide = (p1, p2) ->
				G.twoPointsSameSideOfLine p1, p2, @
			Bu.Line::footPointFrom = (point, saveTo) ->
				G.footPointFromPointToLine point, @, saveTo
			Bu.Line::getCrossPointWith = (line) ->
				G.getCrossPointOfTwoLines line, @
			Bu.Line::isCrossWithLine = (line) ->
				G.isTwoLinesCross line, @

		if 'circle' in shapes
			Bu.Circle::_containsPoint = (point) ->
				G.pointInCircle point, @

		if 'triangle' in shapes
			Bu.Triangle::_containsPoint = (point) ->
				G.pointInTriangle point, @
			Bu.Triangle::area = ->
				G.calcTriangleArea @

		if 'rectangle' in shapes
			Bu.Rectangle::containsPoint = (point) ->
				G.pointInRectangle point, @

		if 'fan' in shapes
			Bu.Fan::_containsPoint = (point) ->
				G.pointInFan point, @

		if 'bow' in shapes
			Bu.Bow::_containsPoint = (point) ->
				G.pointInBow point, @

		if 'polygon' in shapes
			Bu.Polygon::_containsPoint = (point) ->
				G.pointInPolygon point, @

		if 'polyline' in shapes
			Bu.Polygon::length = 0
			Bu.Polygon::pointNormalizedPos = []
			Bu.Polygon::calcLength = () ->
				@length = G.calcPolylineLength @
			Bu.Polygon::calcPointNormalizedPos = ->
				G.calcNormalizedVerticesPosOfPolyline @
			Bu.Polygon::getNormalizedPos = (index) ->
				if index? then @pointNormalizedPos[index] else @pointNormalizedPos
			Bu.Polygon::compress = (strength = 0.8) ->
				G.compressPolyline @, strength

	# Point in shapes

	pointNearPoint: (point, target, limit = Bu.DEFAULT_NEAR_DIST) ->
		point.distanceTo(target) < limit

	pointNearLine: (point, line, limit = Bu.DEFAULT_NEAR_DIST) ->
		verticalDist = line.distanceTo point
		footPoint = line.footPointFrom point

		isBetween1 = footPoint.distanceTo(line.points[0]) < line.length + limit
		isBetween2 = footPoint.distanceTo(line.points[1]) < line.length + limit

		return verticalDist < limit and isBetween1 and isBetween2

	pointNearPolyline: (point, polyline, limit = Bu.DEFAULT_NEAR_DIST) ->
		for line in polyline.lines
			return yes if G.pointNearLine point, line, limit
		no

	pointInCircle: (point, circle) ->
		dx = point.x - circle.cx
		dy = point.y - circle.cy
		return Bu.bevel(dx, dy) < circle.radius

	pointInRectangle: (point, rectangle) ->
		point.x > rectangle.position.x and
				point.y > rectangle.position.y and
				point.x < rectangle.position.x + rectangle.size.width and
				point.y < rectangle.position.y + rectangle.size.height

	pointInTriangle: (point, triangle) ->
		G.twoPointsSameSideOfLine(point, triangle.points[2], triangle.lines[0]) and
				G.twoPointsSameSideOfLine(point, triangle.points[0], triangle.lines[1]) and
				G.twoPointsSameSideOfLine(point, triangle.points[1], triangle.lines[2])

	pointInFan: (point, fan) ->
		dx = point.x - fan.cx
		dy = point.y - fan.cy
		a = Math.atan2(point.y - fan.cy, point.x - fan.cx)
		a += Math.PI * 2 while a < fan.aFrom
		return Bu.bevel(dx, dy) < fan.radius && a > fan.aFrom && a < fan.aTo

	pointInBow: (point, bow) ->
		if Bu.bevel(bow.cx - point.x, bow.cy - point.y) < bow.radius
			sameSide = bow.string.isTwoPointsSameSide(bow.center, point)
			smallThanHalfCircle = bow.aTo - bow.aFrom < Math.PI
			return sameSide ^ smallThanHalfCircle
		else
			return false

	pointInPolygon: (point, polygon) ->
		for triangle in polygon.triangles
			if triangle.containsPoint point
				return true
		false

	# Distance

	distanceFromPointToPoint: (point1, point2) ->
		Bu.bevel point1.x - point2.x, point1.y - point2.y

	distanceFromPointToLine: (point, line) ->
		p1 = line.points[0]
		p2 = line.points[1]
		a = (p1.y - p2.y) / (p1.x - p2.x)
		b = p1.y - a * p1.x
		return Math.abs(a * point.x + b - point.y) / Math.sqrt(a * a + 1)

	# Point Related

	interpolateBetweenTwoPoints: (p1, p2, k, p3) ->
		x = p1.x + (p2.x - p1.x) * k
		y = p1.y + (p2.y - p1.y) * k

		if p3?
			p3.set x, y
		else
			return new Bu.Point x, y

	# Point and Line

	twoPointsSameSideOfLine: (p1, p2, line) ->
		pA = line.points[0]
		pB = line.points[1]
		if pA.x == pB.x
			# if both of the two points are on the line then we consider they are in the same side
			return (p1.x - pA.x) * (p2.x - pA.x) > 0
		else
			y01 = (pA.y - pB.y) * (p1.x - pA.x) / (pA.x - pB.x) + pA.y
			y02 = (pA.y - pB.y) * (p2.x - pA.x) / (pA.x - pB.x) + pA.y
			return (p1.y - y01) * (p2.y - y02) > 0

	footPointFromPointToLine: (point, line, saveTo = new Bu.Point) ->
		p1 = line.points[0]
		p2 = line.points[1]
		A = (p1.y - p2.y) / (p1.x - p2.x)
		B = p1.y - A * p1.x
		m = point.x + A * point.y
		x = (m - A * B) / (A * A + 1)
		y = A * x + B

		saveTo.set x, y
		return saveTo

	getCrossPointOfTwoLines: (line1, line2) ->
		[p1, p2] = line1.points
		[q1, q2] = line2.points

		a1 = p2.y - p1.y
		b1 = p1.x - p2.x
		c1 = (a1 * p1.x) + (b1 * p1.y)
		a2 = q2.y - q1.y
		b2 = q1.x - q2.x
		c2 = (a2 * q1.x) + (b2 * q1.y)
		det = (a1 * b2) - (a2 * b1)

		return new Bu.Point ((b2 * c1) - (b1 * c2)) / det, ((a1 * c2) - (a2 * c1)) / det

	isTwoLinesCross: (line1, line2) ->
		x1 = line1.points[0].x
		y1 = line1.points[0].y
		x2 = line1.points[1].x
		y2 = line1.points[1].y
		x3 = line2.points[0].x
		y3 = line2.points[0].y
		x4 = line2.points[1].x
		y4 = line2.points[1].y

		d = (y2 - y1) * (x4 - x3) - (y4 - y3) * (x2 - x1)

		if d == 0
			return false
		else
			x0 = ((x2 - x1) * (x4 - x3) * (y3 - y1) + (y2 - y1) * (x4 - x3) * x1 - (y4 - y3) * (x2 - x1) * x3) / d
			y0 = ((y2 - y1) * (y4 - y3) * (x3 - x1) + (x2 - x1) * (y4 - y3) * y1 - (x4 - x3) * (y2 - y1) * y3) / -d
		return (x0 - x1) * (x0 - x2) < 0 and
						(x0 - x3) * (x0 - x4) < 0 and
						(y0 - y1) * (y0 - y2) < 0 and
						(y0 - y3) * (y0 - y4) < 0

	# Polyline

	calcPolylineLength: (polyline) ->
		len = 0
		if polyline.vertices.length >= 2
			for i in [1 ... polyline.vertices.length]
				len += polyline.vertices[i].distanceTo polyline.vertices[i - 1]
		return len

	calcNormalizedVerticesPosOfPolyline: (polyline) ->
		currPos = 0
		polyline.pointNormalizedPos[0] = 0
		for i in [1 ... polyline.vertices.length]
			currPos += polyline.vertices[i].distanceTo(polyline.vertices[i - 1]) / polyline.length
			polyline.pointNormalizedPos[i] = currPos

	compressPolyline: (polyline, strength) ->
		compressed = []
		for own i of polyline.vertices
			if i < 2
				compressed[i] = polyline.vertices[i]
			else
				[pA, pM] = compressed[-2..-1]
				pB = polyline.vertices[i]
				obliqueAngle = Math.abs(Math.atan2(pA.y - pM.y, pA.x - pM.x) - Math.atan2(pM.y - pB.y, pM.x - pB.x))
				if obliqueAngle < strength * strength * Math.PI / 2
					compressed[compressed.length - 1] = pB
				else
					compressed.push pB
		polyline.vertices = compressed
		polyline.keyPoints = polyline.vertices
		return polyline

	# Area Calculation

	calcTriangleArea: (triangle) ->
		[a, b, c] = triangle.points
		return Math.abs(((b.x - a.x) * (c.y - a.y)) - ((c.x - a.x) * (b.y - a.y))) / 2

G.inject()