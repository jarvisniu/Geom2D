# Ellipse/Oval Shape

class Bu.Ellipse extends Bu.Object2D

	type: 'Ellipse'
	fillable: yes

	constructor: (@_radiusX = 20, @_radiusY = 10) ->
		super()

	# property

	@property 'radiusX',
		get: -> @_radiusX
		set: (val) ->
			@_radiusX = val
			@trigger 'changed', @


	@property 'radiusY',
		get: -> @_radiusY
		set: (val) ->
			@_radiusY = val
			@trigger 'changed', @