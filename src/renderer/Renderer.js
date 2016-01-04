
var Geom2D = Geom2D || {};

Geom2D.Renderer = function(w, h) {

    Za.EventListenerPattern.apply(this);

    w = w || 800;
    h = h || 450;

    // constants
    var POINT_SIZE = 2;

    // variables
    var _self = this;
    var _dom = document.createElement("canvas");
    var _context;

    var _defaultStrokeStyle = "rgba(255, 0, 0, 0.75)";
    var _defaultFillStyle = "rgba(255, 0, 0, 0.25)";
    var _defaultHoverStyle = "rgba(255, 255, 0, 0.25)";

    var fps = 60;
    var tickCount = 0;

    // API
    this.dom = _dom;
    this.width = w;
    this.height = h;
    this.shapes = [];

    this.append = function(shape) {
        _self.shapes.push(shape);
    };

    function init() {

        _dom.width = w;
        _dom.height = h;
        _dom.style.width = w + "px";
        _dom.style.height = h + "px";
        _dom.style.border = "solid 1px gray";
        _dom.style.cursor = "crosshair";
        _dom.style.background = "#eee";

        _context = _dom.getContext("2d");

        setInterval(tick, 1000 / fps);
    }

    function tick() {
        tickCount ++;
        _self.triggerEvent("update", { "tickCount": tickCount } );
        render();
    }
    // render
    function clearCanvas() {
        _context.clearRect(0, 0, w, h);
    }

    function drawPoint(point) {
        _context.strokeRect (
            point.x - POINT_SIZE / 2,
            point.y - POINT_SIZE / 2,
            POINT_SIZE,
            POINT_SIZE
        );
        if (point.label != null) {
            //console.log("drawPoint(): " + point.label + ", x: " + point.x + ", y: " + point.y);
            var style = _context.fillStyle;
            _context.fillStyle = "black";
            _context.fillText (
                point.label,
                point.x - POINT_SIZE / 2 + 6,
                point.y - POINT_SIZE / 2 + 6);
            _context.fillStyle = style;
        }
    }

    function drawPoints(points) {
        for(var i in points) {
            drawPoint(points[i]);
        }
    }

    function drawLine(line) {
        _context.beginPath();
        _context.lineTo(line.points[0].x, line.points[0].y);
        _context.lineTo(line.points[1].x, line.points[1].y);
        _context.closePath();
        _context.fill();
        _context.stroke();

        drawPoints(line.points);
    }

    function drawCircle(circle) {
        _context.beginPath();
        _context.arc(circle.cx, circle.cy, circle.radius, 0, Math.PI * 2);
        _context.closePath();
        _context.fill();
        _context.stroke();

        drawPoint(circle.centralPoint);
    }

    function drawTriangle(triangle) {
        _context.beginPath();
        _context.lineTo(triangle.points[0].x, triangle.points[0].y);
        _context.lineTo(triangle.points[1].x, triangle.points[1].y);
        _context.lineTo(triangle.points[2].x, triangle.points[2].y);
        _context.closePath();
        _context.fill();
        _context.stroke();

        drawPoints(triangle.points);
    }

    function drawFan(fan) {
        _context.beginPath();
        _context.arc(fan.cx, fan.cy, fan.radius, fan.aFrom, fan.aTo);
        _context.lineTo(fan.cx, fan.cy);
        _context.closePath();
        _context.fill();
        _context.stroke();

        drawPoints(fan.string.points);
    }

    function drawBow(bow) {
        _context.beginPath();
        _context.arc(bow.cx, bow.cy, bow.radius, bow.aFrom, bow.aTo);
        _context.closePath();
        _context.fill();
        _context.stroke();

        drawPoints(bow.string.points);
    }

    function drawPolygon(polygon) {
        _context.beginPath();
        for (var i = 0; i < polygon.points.length; i ++ ) {
            _context.lineTo(polygon.points[i].x, polygon.points[i].y);
        }
        _context.closePath();
        _context.fill();
        _context.stroke();

        drawPoints(polygon.points);
    }

    function drawShapes() {
        for (var i = 0; i < _self.shapes.length; i++) {
            var shape = _self.shapes[i];

            // set styles
            if (shape.strokeStyle != null)
                _context.strokeStyle = shape.strokeStyle;
            else
                _context.strokeStyle = _defaultStrokeStyle;

            if (shape.fillStyle != null)
                _context.fillStyle = shape.fillStyle;
            else
                _context.fillStyle = _defaultFillStyle;

            // draw shape
            if (shape instanceof Geom2D.Point) {
                drawPoint(shape);
            } else if (shape instanceof Geom2D.Line) {
                drawLine(shape);
            } else if (shape instanceof Geom2D.Circle) {
                drawCircle(shape);
            } else if (shape instanceof Geom2D.Triangle) {
                drawTriangle(shape);
            } else if (shape instanceof Geom2D.Fan) {
                drawFan(shape);
            } else if (shape instanceof Geom2D.Bow) {
                drawBow(shape);
            } else if (shape instanceof Geom2D.Polygon) {
                drawPolygon(shape);
            } else {
                console.log("drawShapes(): unknown shape: ", shape);
            }
        }
    }

    function render() {
        clearCanvas();
        drawShapes();
    }

    init();

};
