

function HfcRunner( options ) {
	var frameComplete = true;
	var frameNum = 0;
	var doubleBuffer = false;
	var $canvas[2] = { $("#"+options["canvas0"]), $("#"+options["canvas1"]) };

	var restart = function( startCode, loopCode ) {
		//
		// Kills off any previous running thread and starts the thread again
		//
		
		drawState.reset();

		// CHECK if start code contains a clear, if so use double buffering
		$canvas[1].css( "visibility", "hidden" );
		doubleBuffer = loopCode.match( "^\\s*clear\\s*(\\s*)" ) ? true : false;

		// DELETE the old thread
		$.Hive.destroy();

		frameNum = 0;


??
		defaultMat = $M( [
			[ 1, 0, 0 ], 
			[ 0, 1, 0 ], 
			[ 0, 0, 1 ]
		] ) 
		context[0].setTransform( 1, 0, 0, 1, 0, 0 )
		context[1].setTransform( 1, 0, 0, 1, 0, 0 )
??

		
		// LAUNCH a new thread
		$.Hive.create({
			count: 1,
			worker: '/javascripts/play_worker.js',
			receive: function (data) {
				if( data.cmd == "done" ) {
					setErrorState( data.args[0], data.args[1], data.args[2] );
					frameComplete = true;
				}
				else if( data.cmd == "functions" ) {
					threadReturnedFunctions = data.args;
				}
				else if( data.cmd == "circle" ) {
					drawState.loadStrokeState( context[frameNum%2] );
					context[frameNum%2].beginPath();
					context[frameNum%2].arc( data.args[0], data.args[1], data.args[2], 0, 3.14*2, false );
					context[frameNum%2].closePath();
					context[frameNum%2].stroke();
				}
				else if( data.cmd == "disc" ) {
					drawState.loadFillState( context[frameNum%2] );
					context[frameNum%2].beginPath();
					context[frameNum%2].arc( data.args[0], data.args[1], data.args[2], 0, 3.14*2, false );
					context[frameNum%2].closePath();
					context[frameNum%2].fill();
				}
				else if( data.cmd == "line" ) {
					drawState.loadStrokeState( context[frameNum%2] );
					context[frameNum%2].beginPath();
					context[frameNum%2].moveTo( data.args[0], data.args[1] );
					context[frameNum%2].lineTo( data.args[2], data.args[3] );
					context[frameNum%2].stroke();
				}
				else if( data.cmd == "arc" ) {
					drawState.loadStrokeState( context[frameNum%2] );
					context[frameNum%2].beginPath();
					context[frameNum%2].arc( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5] );
					context[frameNum%2].stroke();
				}
				else if( data.cmd == "box" ) {
					drawState.loadStrokeState( context[frameNum%2] );
					context[frameNum%2].strokeRect( data.args[0], data.args[1], data.args[2], data.args[3] );
				}
				else if( data.cmd == "rect" ) {
					drawState.loadFillState( context[frameNum%2] );
					context[frameNum%2].fillRect( data.args[0], data.args[1], data.args[2], data.args[3] );
				}
				else if( data.cmd == "text" ) {
					drawState.loadFillState( context[frameNum%2] );
					drawState.loadFontState( context[frameNum%2] );
					context[frameNum%2].fillText( data.args[0], data.args[1], data.args[2] );
				}
				else if( data.cmd == "stroketext" ) {
					drawState.loadStrokeState( context[frameNum%2] );
					drawState.loadFontState( context[frameNum%2] );
					context[frameNum%2].strokeText( data.args[0], data.args[1], data.args[2] );
				}
				else if( data.cmd == "font" ) {
					drawState.setFont( data.args[0], data.args[1] );
				}
				else if( data.cmd == "align" ) {
					drawState.setAlign( data.args[0], data.args[1] );
				}

				else if( data.cmd == "fill" ) {
					drawState.setFill( data.args[0], data.args[1], data.args[2], data.args[3] );
				}
				else if( data.cmd == "stroke" ) {
					drawState.setStroke( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5], data.args[6] );
				}
				else if( data.cmd == "shadow" ) {
					drawState.setShadow( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5], data.args[6] );
				}

				else if( data.cmd == "clear" ) {
					context[frameNum%2].setTransform( 1, 0, 0, 1, 0, 0 );
					context[frameNum%2].fillStyle = colorToString( data.args[0], data.args[1], data.args[2] );
					context[frameNum%2].globalAlpha = 1;
					context[frameNum%2].fillRect( 0, 0, canvasW, canvasH );
				}
				else if( data.cmd == "window" ) {
					defaultMat = $M( [
						[ data.args[0], data.args[2], data.args[4] ], 
						[ data.args[1], data.args[3], data.args[5] ], 
						[ 0, 0, 1 ]
					] ) 
					context[frameNum%2].setTransform( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5] );
				}
				else if( data.cmd == "identity" ) {
					context[frameNum%2].setTransform( defaultMat.e(1,1), defaultMat.e(2,1), defaultMat.e(1,2), defaultMat.e(2,2), defaultMat.e(1,3), defaultMat.e(2,3) );
				}
				else if( data.cmd == "translate" ) {
					context[frameNum%2].translate( data.args[0], data.args[1] );
				}
				else if( data.cmd == "scale" ) {
					context[frameNum%2].scale( data.args[0], data.args[1] );
				}
				else if( data.cmd == "rotate" ) {
					context[frameNum%2].rotate( data.args[0] );
				}
				else if( data.cmd == "push" ) {
					context[frameNum%2].save();
				}
				else if( data.cmd == "pop" ) {
					context[frameNum%2].restore();
				}
				
				else if( data.cmd == "beginPath" ) {
					context[frameNum%2].beginPath();
				}
				else if( data.cmd == "closePath" ) {
					context[frameNum%2].closePath();
				}
				else if( data.cmd == "moveTo" ) {
					context[frameNum%2].moveTo( data.args[0], data.args[1] );
				}
				else if( data.cmd == "lineTo" ) {
					context[frameNum%2].lineTo( data.args[0], data.args[1] );
				}
				else if( data.cmd == "curveTo" ) {
					context[frameNum%2].quadraticCurveTo( data.args[0], data.args[1], data.args[2], data.args[3] );
				}
				else if( data.cmd == "bezierTo" ) {
					context[frameNum%2].bezierCurveTo( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5] );
				}
				else if( data.cmd == "arcTo" ) {
					context[frameNum%2].arcTo( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4] );
				}
				else if( data.cmd == "pathArc" ) {
					context[frameNum%2].arc( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5] );
				}
				else if( data.cmd == "strokePath" ) {
					drawState.loadStrokeState( context[frameNum%2] );
					context[frameNum%2].stroke();
				}
				else if( data.cmd == "fillPath" ) {
					drawState.loadFillState( context[frameNum%2] );
					context[frameNum%2].fill();
				}
				else if( data.cmd == "alpha" ) {
					drawState.setAlpha( data.args[0] );
				}
				else if( data.cmd == "composite" ) {
					drawState.setComposite( data.args[0] );
				}
				else if( data.cmd == "gradient" ) {
					drawState.createGradient( data.args[0], data.args[1], data.args[2], data.args[3] );
				}
				else if( data.cmd == "gradientRadial" ) {
					drawState.createGradientRadial( data.args[0], data.args[1], data.args[2], data.args[3], data.args[4], data.args[5] );
				}
				else if( data.cmd == "addColorStop" ) {
					drawState.addColorStop( data.args[0], data.args[1], data.args[2], data.args[3] );
				}
				else if( data.cmd == "debug" ) {
					$("#debugStream").append( data.args[0] + "<br/>" );
					$("#debugStream").scrollTop($("#debugStream")[0].scrollHeight);
					console.log( data.args[0] );
				}

				else if( data.cmd == "image" ) {
					var i = images[ data.args[0] ];
					if( ! i ) {
						i = new Image();
						if( data.args[0].match( /http(s)?:/ ) ) {
							i.src = data.args[0];
						}
						else {
							i.src = "/home/get_asset?name=" + data.args[0];
						}
						i.onload = getImageDims;
						images[ data.args[0] ] = i;
					}
					if( data.args[5] != null ) {
						context[frameNum%2].drawImage( i, data.args[5], data.args[6], data.args[7], data.args[8], data.args[1], data.args[2], data.args[3], data.args[4] );
					}
					else if( data.args[3] != null ) {
						context[frameNum%2].drawImage( i, data.args[1], data.args[2], data.args[3], data.args[4] );
					}
					else {
						context[frameNum%2].drawImage( i, data.args[1], data.args[2] );
					}
				}
				
				else if( data.cmd == "unresponsiveOverride" ) {
					unresponsiveOverride = true
				}
			}
		});

		codeBlocks = [];
		codeBlockNames = [];
		for( var i in publicFunctions ) {
			codeBlockNames.push( i );
			codeBlocks.push( publicFunctions[i] );
		}
		codeBlocks.push( startCode );
		codeBlockNames.push( "Start code" );
		
		setErrorState( "", "", "" );
		$.Hive.get(0).send( [codeBlockNames,codeBlocks,null,0,0,false,null,null,imageDims,false] );

		frameComplete = false;
	}
	}

	var runFrame = function( state ) {
		// Tells the thread to run one frame
	}
}




/*
var savePower = false;

var frameComplete = true;
var frameNum = 0;
var context = [];
var canvasW = 350;
var canvasH = 350;
var mouseX=0, mouseY=0, mouseDown=false;
var keyDown=null;
var doubleBuffer = false;

var drawState = new DrawState();
var images = [];

var challengeStartCode = null;
var challengeLoopCode = null;

var startFrameTime;
var unresponsiveOverride = false

var defaultMat = $M( [

imageDims = {};
function getImageDims() {

var errorInLoopCode = false;
function setErrorState( blockName, exceptMessage, exceptLine ) {

function colorToString( r, g, b ) {

function DrawState() {



var frameRates = [];
var count = 0
var stopWaitTime;
var startWaitTime;



// public functions
//===================================================================================

var publicFunctions = [];
var publicFunctionsLoad = [];
var publicFunctionsEditting = "";

function clearFunctions() {
function updateFunctionsCode() {
function bindFunction( name ) {
*/