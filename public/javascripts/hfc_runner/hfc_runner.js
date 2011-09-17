
var HfcRunner = (function ($,$M) {
	var my = {};

	function HfcDrawState() {
		this.fill = "#000000";
		this.fillA = 1;
		this.lineWidth = 1;
		this.lineCap = "butt";
		this.lineJoin = "miter";
		this.stroke = "#000000";
		this.strokeA = 1;
		this.gradient = null;
		this.shadowX = 0;
		this.shadowY = 0;
		this.shadowBlur = 2;
		this.shadowColor = "#000000";
		this.font = "";
		this.textAlign = "left";
		this.textBaseline = "top";
		this.defaultMat = $M( [
			[ 1, 0, 0 ], 
			[ 0, 1, 0 ], 
			[ 0, 0, 1 ]
		] );

		this.setFill = function( r, g, b, a ) {
			this.gradient = null
			this.fill = colorToString( r, g, b )
			this.fill = "#" + this.fill.substring( 1, 7 )
			this.fillA = a
		}
		
		this.setAlpha = function( a ) {
			this.fillA = a
		}
		
		this.setStroke = function( w, r, g, b, a, cap, join ) {
			this.lineWidth = w
			this.stroke = colorToString( r, g, b )
			this.strokeA = a
			this.lineCap = cap
			this.lineJoin = join
		}
		
		this.setShadow = function( x, y, blur, r, g, b ) {
			this.shadowX = x
			this.shadowY = y
			this.shadowBlur = blur
			this.shadowColor = colorToString( r, g, b )
		}

		this.setFont = function( name, size ) {
			this.font = size + "px " + name
		}

		this.setAlign = function( align, baseline ) {
			this.textAlign = align
			this.textBaseline = baseline
		}

		this.createGradient = function( x0, y0, x1, y1 ) {
			this.gradient = context[0].createLinearGradient(x0,y0,x1,y1)
		}
		
		this.createGradientRadial = function( x0, y0, r0, x1, y1, r1 ) {
			this.gradient = context[0].createRadialGradient(x0,y0,r0,x1,y1,r1)
		}
		
		this.addColorStop = function( p, r, g, b ) {
			this.gradient.addColorStop( p, colorToString( r, g, b ) )
		}

		this.loadFillState = function(context) {
			context.fillStyle = this.gradient ? this.gradient : this.fill
			context.globalAlpha = this.fillA
			if( this.shadowX == 0 && this.shadowY == 0 ) {
				context.shadowOffsetX = null
				context.shadowOffsetY = null
				context.shadowBlur = null
				context.shadowColor = null
			}
			else {
				context.shadowOffsetX = this.shadowX
				context.shadowOffsetY = this.shadowY
				context.shadowBlur = this.shadowBlur
				context.shadowColor = this.shadowColor
			}
		}
		
		this.loadStrokeState = function(context) {
			var minScale = Math.min( Math.abs(this.defaultMat.e(1,1)), Math.abs(this.defaultMat.e(2,2)) )
			context.lineWidth = this.lineWidth / minScale
			context.strokeStyle = this.stroke
			context.globalAlpha = this.strokeA
			context.lineCap = this.lineCap
			context.lineJoin = this.lineJoin
		}
		
		this.loadFontState = function( context ) {
			context.font = this.font
			context.textAlign = this.textAlign
			context.textBaseline = this.textBaseline
		}
		
		this.reset = function() {
			this.setFill( 0, 0, 0, 1 )
			this.setStroke( 1, 0, 0, 0, 1, "butt", "miter" )
			this.setShadow( 0, 0, 2, 0, 0, 0 )
			this.setFont( "Calibri", 20 )
			this.setAlign( "left", "top" )
		}
	}
	
	var HfcFunctions = {
		addColorStop: function( a, b, c, d ) {
			drawState.addColorStop( a, b, c, d );
		},
		
        align: function( a, b ) {
			drawState.setAlign( a, b );
        },
		
		alpha: function( a ) {
			drawState.setAlpha( a );
		},
		
		arc: function( x, y, r, a0, a1, dir ) {
			drawState.loadStrokeState( currentContext );
			currentContext.beginPath();
			currentContext.arc( x, y, r, a0, a1, dir );
			currentContext.stroke();
		},

		arcTo: function( a, b, c, d, e ) {
			currentContext.arcTo( a, b, c, d, e );
		},
		
		beginPath: function() {
			currentContext.beginPath();
		},
		
		bezierTo: function( cx0, cy0, cx1, cy1, x, y ) {
			currentContext.bezierCurveTo( cx0, cy0, cx1, cy1, x, y );
		},
		
		box: function( x0, y0, w, h ) {
			drawState.loadStrokeState( currentContext );
			currentContext.strokeRect( x0, y0, w, h );
		},

		circle: function( x, y, r ) {
			drawState.loadStrokeState( currentContext );
			currentContext.beginPath();
			currentContext.arc( x, y, r, 0, 3.141592654*2, false );
			currentContext.closePath();
			currentContext.stroke();
		},

		clear: function( r, g, b ) {
			currentContext.setTransform( 1, 0, 0, 1, 0, 0 );
			currentContext.fillStyle = colorToString( r, g, b );
			currentContext.globalAlpha = 1;
			currentContext.fillRect( 0, 0, canvasW, canvasH );
		},
	
		closePath: function() {
			currentContext.closePath();
		},
		
		composite: function( a ) {
			drawState.setComposite( a );
		},
		
		curveTo: function( x, y, a, b ) {
			currentContext.quadraticCurveTo( x, y, a, b );
		},
		
		disc: function( x, y, r ) {
			drawState.loadFillState( context[frameNum%2] );
			currentContext.beginPath();
			currentContext.arc( x, y, r, 0, 3.14*2, false );
			currentContext.closePath();
			currentContext.fill();
		},

		fill: function( r, g, b, a ) {
			drawState.setFill( r, g, b, a );
        },
		
		fillPath: function() {
			drawState.loadFillState( currentContext );
			currentContext.fill();
		},
		
		font: function( t, s ) {
			drawState.setFont( t, s );
        },
		
		gradient: function( x0, y0, x1, y1 ) {
			drawState.createGradient( x0, y0, x1, y1 );
		},
		
		gradientRadial: function( x0, y0, r0, x1, y1, r1 ) {
			drawState.createGradientRadial( x0, y0, r0, x1, y1, r1 );
		},
		
		identity: function() {
			currentContext.setTransform( defaultMat.e(1,1), defaultMat.e(2,1), defaultMat.e(1,2), defaultMat.e(2,2), defaultMat.e(1,3), defaultMat.e(2,3) );
		},
		
		image: function( url, x, y, w, h, sx, sy, sw, sh ) {
			var i = images[ url ];
			if( ! i ) {
				i = new Image();
				if( url.match( /http(s)?:/ ) ) {
					i.src = url;
				}
				else {
					i.src = "/assets/show_by_name?name=" + url;
				}
				i.onload = getImageDims;
				images[ url ] = i;
			}
			if( sx != null ) {
				currentContext.drawImage( i, sx, sy, sw, sh, x, y, w, h );
			}
			else if( w != null ) {
				currentContext.drawImage( i, x, y, w, h );
			}
			else {
				currentContext.drawImage( i, x, y );
			}
		},
		
		line: function( x0, y0, x1, y1 ) {
			drawState.loadStrokeState( currentContext );
			currentContext.beginPath();
			currentContext.moveTo( x0, y0 );
			currentContext.lineTo( x1, y1 );
			currentContext.stroke();
		},

		lineTo: function( x, y ) {
			currentContext.lineTo( x, y );
		},
		
		moveTo: function( x, y ) {
			currentContext.moveTo( x, y );
		},
		
		pathArc: function( a, b, c, d, e, f ) {
			currentContext.arc( a, b, c, d, e, f );
		},
		
		push: function() {
			currentContext.save();
		},
		
		pop: function() {
			currentContext.restore();
		},
		
		rect: function( x0, y0, w, h ) {
			drawState.loadFillState( currentContext );
			currentContext.fillRect( x0, y0, w, h );
		},

		rotate: function( a ) {
			currentContext.rotate( a );
		},
		
		scale: function( x, y ) {
			currentContext.scale( x, y );
		},
		
        shadow: function( x, y, blur, r, g, b ) {
			drawState.setShadow( x, y, blur, r, g, b );
		},
		
        stroke: function( w, r, g, b, a, cap, join ) {
			drawState.setStroke( w, r, g, b, a, cap, join );
        },
		
		strokePath: function() {
			drawState.loadStrokeState( currentContext );
			currentContext.stroke();
		},
		
		strokeText: function( s, x, y ) {
			drawState.loadStrokeState( currentContext );
			drawState.loadFontState( currentContext );
			currentContext.strokeText( s, x, y );
		},
		
		text: function( s, x, y ) {
			drawState.loadFillState( currentContext );
			drawState.loadFontState( currentContext );
			currentContext.fillText( s, x, y );
		},

		translate: function( x, y ) {
			currentContext.translate( x, y );
		},
		
		window: function( a, b, c, d, e, f ) {
			defaultMat = $M( [
				[ a, c, e ], 
				[ b, d, f ], 
				[ 0, 0, 1 ]
			] ) 
			currentContext.setTransform( a, b, c, d, e, f );
		},
		
		
		//unresponsiveOverride: function() {
		//	unresponsiveOverride = true;
		//},

//		else if( data.cmd == "debug" ) {
//			$("#debugStream").append( data.args[0] + "<br/>" );
//			$("#debugStream").scrollTop($("#debugStream")[0].scrollHeight);
//			console.log( data.args[0] );
//		}

	};

	var frameComplete = true;
	var frameNum = 0;
	var $canvas = [];
	var context = [];
	var currentContext = null;
	var drawState = HfcDrawState;
	var startCode = "";
	var loopCode = "";
	var doubleBuffer = false;
	var canvasW = 350;
	var canvasH = 350;
	var drawState = new HfcDrawState();
	var errorInLoopCode = false;
	var frameRates = [];
	var startFrameTime = new Date().getTime();
	var frameCallback = null;
	var errorStateCallback = null;
	var twiddlers = {};
	var mouseX = 0;
	var mouseY = 0;
	var mouseDown = false;
	var keyDown = null;
	var imageDims = {};
	var images = {};
	
	colorToString = function( r, g, b ) {
		r = Math.max( 1, Math.min( 255, r*255 ) );
		g = Math.max( 1, Math.min( 255, g*255 ) );
		b = Math.max( 1, Math.min( 255, b*255 ) );
		var color = ( (1<<24) | (r<<16) | (g<<8) | b ).toString(16);
		return "#" + color.substring( 1, 7 );
	}

	getImageDims = function() {
		for( var i in images ) {
			imageDims[i] = [ images[i].width, images[i].height ];
		}
	}
	
	my.init = function( options ) {
		$canvas[0] = $("#"+options["canvasId0"]);
		$canvas[1] = $("#"+options["canvasId1"])
		var mainCanvas0 = document.getElementById( options["canvasId0"] );
		var mainCanvas1 = document.getElementById( options["canvasId1"] );
		context[0] = mainCanvas0.getContext("2d");
		context[1] = mainCanvas1.getContext("2d");
		mainCanvas0.setAttribute( "width", canvasW );
		mainCanvas0.setAttribute( "height", canvasH );
		mainCanvas0.width = mainCanvas0.width; // forces a reset
		mainCanvas1.setAttribute( "width", canvasW );
		mainCanvas1.setAttribute( "height", canvasH );
		mainCanvas1.width = mainCanvas1.width; // forces a reset
		$canvas[1].css( "position", "absolute" );
		$canvas[1].css( "left", $canvas[0].position().left );
		$canvas[1].css( "top", $canvas[0].position().top );
		frameCallback = options.frameCallback;
		errorStateCallback = options.errorStateCallback;

		$(window).mousemove( function(event) {
			var off = $canvas[0].offset();
			mouseX = event.pageX - off.left;
			mouseY = event.pageY - off.top;
		});

		$canvas[0].mousedown( function(event) {
			mouseDown = true;
		});

		$canvas[1].mousedown( function(event) {
			mouseDown = true;
		});

		$(window).mouseup( function(event) {
			mouseDown = false;
		});

		$(document).keydown( function(event) {
			keyDown = event.which;
		});

		$(document).keyup( function(event) {
			keyDown = null;
		});
		
	};
	
	my.stop = function() {
		startCode = "";
		loopCode = "";
		$("#mainCanvas0").css( "visibility", "visible" );
		$("#mainCanvas1").css( "visibility", "hidden" );
		context[0].setTransform( 1, 0, 0, 1, 0, 0 );
		context[0].fillStyle = "#FFFFFF";
		context[0].globalAlpha = 1;
		context[0].fillRect( 0, 0, canvasW, canvasH );
		$("#mainCanvas1").css( "visibility", "visible" );
		context[1].setTransform( 1, 0, 0, 1, 0, 0 );
		context[1].fillStyle = "#FFFFFF";
		context[1].globalAlpha = 1;
		context[1].fillRect( 0, 0, canvasW, canvasH );
		$("#mainCanvas1").css( "visibility", "hidden" );
	}

	my.restart = function( _startCode, _loopCode, _twiddlers ) {
		startCode = _startCode;
		loopCode = _loopCode;
		twiddlers = _twiddlers;
		
		drawState.reset();

		// DELETE the old thread
		$.Hive.destroy();

		frameNum = 0;
		currentContext = context[0];

		// CHECK for clear to determine if we are double buffering
		$canvas[1].css( "visibility", "hidden" );
		doubleBuffer = loopCode.match( "^\\s*clear\\s*(\\s*)" ) ? true : false;

		// LAUNCH a new thread
		$.Hive.create({
			count: 1,
			worker: '/javascripts/hfc_runner/hfc_run_worker.js',
			receive: function (data) {
				if( data.cmd == "done" ) {
					errorStateCallback( data.args[0], data.args[1], data.args[2] );
					errorInLoopCode = data.args[1] && data.args[0] == "Loop code";
					frameComplete = true;
				}
				else {
					HfcFunctions[data.cmd].apply( this, data.args );
				}
			}
		});

		codeBlocks = [];
		codeBlockNames = [];
		codeBlocks.push( startCode );
		codeBlockNames.push( "Start code" );

		// TELL the thread to run the startup block(s)
		$.Hive.get(0).send( [codeBlockNames, codeBlocks, null, 0, 0, false, null, null, imageDims, false] );
		frameComplete = false;
		setTimeout( runFrame, 1 );
	}

	runFrame = function() {
		// POLL to see if the thread has completed a frame.  If so, send a message telling the
		// thread of the current state and it will then run one more frame.
		if( frameComplete ) {
			if( $.Hive.get(0) ) {
				// COMPUTE FPS
				var stopFrameTime = new Date().getTime();
				var frameRate = 1000.0 / (stopFrameTime - startFrameTime);
				frameRates[ frameNum % 20 ] = frameRate;
				var avgFrameRate = 0;
				for( var i=0; i<20; i++ ) {
					avgFrameRate += frameRates[i];
				}
				frameCallback( avgFrameRate / 20 )
				startFrameTime = new Date().getTime();

				twiddlerArray = [];
				for( i in twiddlers ) {
					twiddlerArray.push( i );
					twiddlerArray.push( parseFloat(twiddlers[i]) );
				}

				// TELL the server to run the loop code
				$.Hive.get(0).send( [ ["Loop code"], [loopCode], keyDown, mouseX, mouseY, mouseDown, null, twiddlerArray, imageDims, true ] );
				frameComplete = false;
			}

			frameNum++;
			if( doubleBuffer && ! errorInLoopCode ) {
				$canvas[1].css( "visibility", frameNum % 2 == 0 ? "visible" : "hidden" );
				currentContext = context[ frameNum % 2 ];
			}
			else {
				$canvas[1].css( "visibility", "hidden" );
				currentContext = context[ 0 ];
			}
		}
		setTimeout( runFrame, 1 );
	}
	
	return my;
}($,$M));

