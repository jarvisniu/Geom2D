# polyline shape

class Bu.Polyline extends Bu.Object2D

	constructor: (@vertices = []) ->
		super()
		@type = 'Polyline'

		if arguments.length > 1
			vertices = []
			for i in [0 ... arguments.length / 2]
				vertices.push new Bu.Point arguments[i * 2], arguments[i * 2 + 1]
			@vertices = vertices

		@lines = []
		@length = 0
		@pointNormalizedPos = []
		@keyPoints = @vertices

		@fill off

		@on "pointChange", =>
			if @vertices.length > 1
				@updateLines()
				@calcLength()
				@calcPointNormalizedPos()
		@trigger "pointChange", @

	clone: => new Bu.Polyline @vertices

	updateLines: =>
		for i in [0 ... @vertices.length - 1]
			if @lines[i]?
				@lines[i].set @vertices[i], @vertices[i + 1]
			else
				@lines[i] = new Bu.Line @vertices[i], @vertices[i + 1]
	# TODO remove the rest

	calcLength: =>
		if @vertices.length < 2
			@length = 0
		else
			len = 0
			for i in [1 ... @vertices.length]
				len += @vertices[i].distanceTo @vertices[i - 1]
			@length = len

	calcPointNormalizedPos: () ->
		currPos = 0
		@pointNormalizedPos[0] = 0
		for i in [1 ... @vertices.length]
			currPos += @vertices[i].distanceTo(@vertices[i - 1]) / @length
			@pointNormalizedPos[i] = currPos

	getNormalizedPos: (index) ->
		if index?
			return @pointNormalizedPos[index]
		else
			return @pointNormalizedPos

	compress: (strength = 0.8) ->
		compressed = []
		for own i of @vertices
			if i < 2
				compressed[i] = @vertices[i]
			else
				[pA, pM] = compressed[-2..-1]
				pB = @vertices[i]
				obliqueAngle = Math.abs(Math.atan2(pA.y - pM.y, pA.x - pM.x) - Math.atan2(pM.y - pB.y, pM.x - pB.x))
				if obliqueAngle < strength * strength * Math.PI / 2
					compressed[compressed.length - 1] = pB
				else
					compressed.push pB
		@vertices = compressed
		@keyPoints = @vertices
		@

	# edit

	set = (points) ->
		# points
		for i in [0 ... @vertices.length]
			@vertices[i].copy points[i]

		# remove the extra points
		if @vertices.length > points.length
			@vertices.splice points.length

		@trigger "pointChange", @

	addPoint: (point, insertIndex) ->
		if not insertIndex?
			# add point
			@vertices.push point
			# add line
			if @vertices.length > 1
				@lines.push new Bu.Line @vertices[@vertices.length - 2], @vertices[@vertices.length - 1]
		else
			@vertices.splice insertIndex, 0, point
		# TODO add lines
		@trigger "pointChange", @
