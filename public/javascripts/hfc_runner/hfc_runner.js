
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
		clear: function( r, g, b ) {
			currentContext.setTransform( 1, 0, 0, 1, 0, 0 );
			currentContext.fillStyle = colorToString( r, g, b );
			currentContext.globalAlpha = 1;
			currentContext.fillRect( 0, 0, canvasW, canvasH );
		},
	
		circle: function( x, y, r ) {
			drawState.loadStrokeState( currentContext );
			currentContext.beginPath();
			currentContext.arc( x, y, r, 0, 3.141592654*2, false );
			currentContext.closePath();
			currentContext.stroke();
		},

		box: function( x, y, w, h ) {
		}
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

	colorToString = function( r, g, b ) {
		r = Math.max( 1, Math.min( 255, r*255 ) );
		g = Math.max( 1, Math.min( 255, g*255 ) );
		b = Math.max( 1, Math.min( 255, b*255 ) );
		var color = ( (1<<24) | (r<<16) | (g<<8) | b ).toString(16);
		return "#" + color.substring( 1, 7 );
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
	};

	my.restart = function( _startCode, _loopCode ) {
		//
		// Kills off any previous running thread and starts the thread again
		//
		
		startCode = _startCode;
		loopCode = _loopCode;
		
		drawState.reset();

		// DELETE the old thread
		$.Hive.destroy();

		frameNum = 0;
		currentContext = context[0];

		// LAUNCH a new thread
		$.Hive.create({
			count: 1,
			worker: '/javascripts/hfc_runner/hfc_run_worker.js',
			receive: function (data) {
				if( data.cmd == "done" ) {
					//setErrorState( data.args[0], data.args[1], data.args[2] );
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
		$.Hive.get(0).send( [codeBlockNames,codeBlocks,null,0,0,false,null,null,[]/*imageDims*/,false] );
		frameComplete = false;
		setTimeout( my.runFrame, 1 );
	}

	my.runFrame = function( state ) {
		// POLL to see if the thread has completed a frame.  If so, send a message telling the
		// thread of the current state and it will then run one more frame.
		if( frameComplete ) {
			if( $.Hive.get(0) ) {
				// TELL the server to run the loop code
//				$.Hive.get(0).send( [ ["Loop code"], [loopCode], keyDown, mouseX, mouseY, mouseDown, null, twiddlerArray, imageDims, true ] );
				$.Hive.get(0).send( [ ["Loop code"], [loopCode], false, 0, 0, false, null, [], [], true ] );
				frameComplete = false;
			}

			if( doubleBuffer && ! errorInLoopCode ) {
				frameNum++;
				$canvas[1].css( "visibility", frameNum % 2 == 0 ? "visible" : "hidden" );
				currentContext = context[ frameNum % 2 ];
			}
			else {
				$canvas[1].css( "visibility", "hidden" );
				currentContext = context[ 0 ];
			}
		}
		setTimeout( my.runFrame, 1 );
	}
	
	return my
}($,$M));

