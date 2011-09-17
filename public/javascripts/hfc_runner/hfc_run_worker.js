importScripts('/javascripts/jquery.hive.pollen.js');
importScripts('/javascripts/sylvester.js');
with( Math ) {

	var _keyDown, _mouseX, _mouseY, _mouseDown, _imageDims;
	var _defaultMat = Matrix.I( 3 );
	var _transform = Matrix.I( 3 );

	// runFrame:
	//   This function is called by the web-worker threading interface once per frame.
	//   Because these threads can not talk to the DOM directly there is quite of bit
	//   of messaging that has to pass state back and forth.
	//   Firefox has a bug that prevents sending dictionaries to the worker so the
	//   state is transferred in an ugly array
	//==========================================================================================
	$(function( data ) {

		var codeBlockNames = data.message[0];
		var codeBlocks = data.message[1];
		_keyDown = data.message[2];
		_mouseX = data.message[3];
		_mouseY = data.message[4];
		_mouseDown = data.message[5];
		searchForSymbols = data.message[6];
		twiddlers = data.message[7];
		_imageDims = data.message[8];
		var isLoopCode = data.message[9];
		if( isLoopCode ) {
			_transform = Matrix.I(3);
		}

		if( twiddlers ) {
			for( var i=0; i<twiddlers.length; i+=2 ) {
				self[ twiddlers[i] ] = twiddlers[i+1]
			}
		}
    
		if( searchForSymbols ) {

			var returnSymbols = { "fakeSymbol":"" };
				// The fakeSymbol is there so that SOMETHING is returned

			for( var __p in self ) {
				if( __p.match( /^\$/ ) && __p != "$" ) {
					returnSymbols[__p.toString()] = self[__p].toString();
				}
			}

			$.send( { "cmd":"functions", "args":returnSymbols } );
			return;
		}

		var i;
		var exceptMessage = null;
		var exceptLine = 0;
		var blockName = null;
		try {
			for( i=0; i<codeBlocks.length; i++ ) {
				blockName = codeBlockNames[i];
				eval( codeBlocks[i] );
			}
		}
		catch( e ) {
			exceptMessage = e.message;
			exceptLine = e.lineNumber - 20;
		}

		$.send( { "cmd":"done", "args":[blockName,exceptMessage,exceptLine] } );
	});

	// IO
	//=======================================================================================

	function keyDown() {
		if( _keyDown ) {
			return String.fromCharCode( _keyDown );
		}
		return null;
	}

	function mouseX() {
		return _mouseX;
	}

	function mouseY() {
		return _mouseY;
	}

	function mouseDown() {
		return _mouseDown;
	}

	function time() {
		return new Date().getTime();
	}

	function debug( str ) {
		$.send( { "cmd":"debug", "args":[str] } );
	}

	function unresponsiveOverride() {
		$.send( { "cmd":"unresponsiveOverride" } )
	}

	function delay( t ) {
		var start = new Date().getTime();
		while( true ) {
			var now = new Date();
			if( now.getTime() - start > t ) {
				break;
			}
		}
	}

	// Math
	//=======================================================================================

	function rand(x,y) {
		if( typeof(x) == "undefined" ) {
			x = 0;
			y = 1;
		}
		if( typeof(y) == "undefined" ) {
			y = x;
			x = 0;
		}
		return Math.random()*(y-x)+x;
	}

	function randi(x,y) {
		if( typeof(x) == "undefined" ) {
			x = 0;
			y = 2;
		}
		if( typeof(y) == "undefined" ) {
			y = x;
			x = 0;
		}
		return Math.floor( Math.random()*(y-x)+x );
	}

	function pi() {
		return Math.PI;
	}

	function pi2() {
		return 2*Math.PI;
	}

	function e() {
		return Math.E;
	}

	function distance( x0, y0, x1, y1 ) {
		dx = x1-x0;
		dy = y1-y0;
		return Math.sqrt( dx*dx + dy*dy );
	}

	// Graphics
	//=======================================================================================

	function width() {
		return 350;
	}

	function height() {
		return 350;
	}

	function cenX() {
		return 175;
	}

	function cenY() {
		return 175;
	}

	function fill( r, g, b, a ) {
		if( typeof(r) == "undefined" ) r = 0;
		if( typeof(g) == "undefined" ) g = 0;
		if( typeof(b) == "undefined" ) b = 0;
		if( typeof(a) == "undefined" ) a = 1;
		$.send( { "cmd":"fill", "args":[r, g, b, a] } );
	}

	function shadow( x, y, blur, r, g, b ) {
		if( typeof(blur) == "undefined" ) blur = 2;
		if( typeof(r) == "undefined" ) r = 0;
		if( typeof(g) == "undefined" ) g = 0;
		if( typeof(b) == "undefined" ) b = 0;
		$.send( { "cmd":"shadow", "args":[x, y, blur, r, g, b] } );
	}

	function circle( x, y, r ) {
		$.send( { "cmd":"circle", "args":[x,y,r] } );
	}

	function disc( x, y, r ) {
		$.send( { "cmd":"disc", "args":[x,y,r] } );
	}

	function line( x0, y0, x1, y1 ) {
		$.send( { "cmd":"line", "args":[x0,y0,x1,y1] } );
	}

	function arc( cx, cy, r, a0, a1, ac ) {
		if( typeof(ac) == "undefined" ) ac = false;
		$.send( { "cmd":"arc", "args":[cx,cy,r,a0,a1,ac] } );
	}

	function pathBegin() {
		$.send( { "cmd":"beginPath" } );
	}

	function pathClose() {
		$.send( { "cmd":"closePath" } );
	}

	function pathMoveTo( x, y ) {
		$.send( { "cmd":"moveTo", "args":[x,y] } );
	}

	function pathLineTo(x,y) {
		$.send( { "cmd":"lineTo", "args":[x,y] } );
	}

	function pathCurveTo(cx,cy,x,y) {
		$.send( { "cmd":"curveTo", "args":[cx,cy,x,y] } );
	}

	function pathBezierTo(cx0,cy0,cx1,cy1,x,y) {
		$.send( { "cmd":"bezierTo", "args":[cx0,cy0,cx1,cy1,x,y] } );
	}

	function pathArcTo(x0,y0,x1,y1,r) {
		$.send( { "cmd":"arcTo", "args":[x0,y0,x1,y1,r] } );
	}

	function pathArc(x,y,r,a0,a1,antiClock) {
		if( typeof(antiClock) == "undefined" ) antiClock = false;
		$.send( { "cmd":"pathArc", "args":[x,y,r,a0,a1,antiClock] } );
	}

	function pathStroke() {
		$.send( { "cmd":"strokePath" } );
	}

	function pathFill() {
		$.send( { "cmd":"fillPath" } );
	}

	function gradient( x0, y0, x1, y1 ) {
		$.send( { "cmd":"gradient", "args":[x0,y0,x1,y1] } );
	}

	function gradientRadial( x0, y0, r0, x1, y1, r1 ) {
		$.send( { "cmd":"gradientRadial", "args":[x0,y0,r0,x1,y1,r1] } );
	}

	function gradientAddColor( p, r, g, b ) {
		$.send( { "cmd":"addColorStop", "args":[p,r,g,b] } );
	}

	function stroke( w, r, g, b, a, cap, join ) {
		if( typeof(w) == "undefined" ) w = 1;
		if( typeof(r) == "undefined" ) r = 0;
		if( typeof(g) == "undefined" ) g = 0;
		if( typeof(b) == "undefined" ) b = 0;
		if( typeof(a) == "undefined" ) a = 1;
		if( typeof(cap) == "undefined" ) cap="butt";
		if( typeof(join) == "undefined" ) cap="miter";
		$.send( { "cmd":"stroke", "args":[w,r,g,b,a,cap,join] } );
	}

	function clear( r, g, b ) {
		if( typeof(r) == "undefined" ) r = 1;
		if( typeof(g) == "undefined" ) g = 1;
		if( typeof(b) == "undefined" ) b = 1;
		$.send( { "cmd":"clear", "args":[r,g,b] } );
	}

	function box( x, y, w, h ) {
		$.send( { "cmd":"box", "args":[x,y,w,h] } );
	}

	function rect( x, y, w, h ) {
		$.send( { "cmd":"rect", "args":[x,y,w,h] } );
	}

	function alpha( a ) {
		$.send( { "cmd":"alpha", "args":[a] } );
	}

	function imageWidth( name ) {
		if( typeof _imageDims != "undefined" && typeof _imageDims[name] != "undefined" ) {
			return _imageDims[name][0];
		}
		return 0;
	}

	function imageHeight( name ) {
		if( typeof _imageDims != "undefined" && typeof _imageDims[name] != "undefined" ) {
			return _imageDims[name][1];
		}
		return 0;
	}

	function image( i, x, y, w, h, sx, sy, sw, sh ) {
		if( typeof(x) == "undefined" ) x = 0;
		if( typeof(y) == "undefined" ) y = 0;
		$.send( { "cmd":"image", "args":[i,x,y,w,h,sx,sy,sw,sh] } );
	}

	function text( a, x, y ) {
		if( typeof(x) == "undefined" ) x = 0;
		if( typeof(y) == "undefined" ) y = 0;
		$.send( { "cmd":"text", "args":[a,x,y] } );
	}

	function strokeText( a, x, y ) {
		if( typeof(x) == "undefined" ) x = 0;
		if( typeof(y) == "undefined" ) y = 0;
		$.send( { "cmd":"strokeText", "args":[a,x,y] } );
	}

	function font( size, name ) {
		if( typeof(name) == "undefined" ) name = "Calibri";
		if( typeof(size) == "undefined" ) size = 20;
		$.send( { "cmd":"font", "args":[name,size] } );
	}

	function align( align, baseline ) {
		if( typeof(align) == "undefined" ) align = "left";
		if( typeof(baseline) == "undefined" ) baseline = "top";
		$.send( { "cmd":"align", "args":[align,baseline] } );
	}

	function window( x0,y0, x1,y1 ) {
		var sx = width() / (x1-x0)
		var sy = height() / (y1-y0)
		_defaultMat = $M( [
			[ sx, 0, -x0*sx ], 
			[ 0, sy, -y0*sy ], 
			[ 0, 0, 1 ]
		] ) 
		_transform = _defaultMat
		$.send( { "cmd":"window", "args":[sx,0,0,sy,-x0*sx,-y0*sy] } );
	}

	function identity() {
		_transform = _defaultMat
		$.send( { "cmd":"identity" } );
	}

	function translate( x, y ) {
		var m = $M( [
			[ 1, 0, x ], 
			[ 0, 1, y ], 
			[ 0, 0, 1 ]
		] ); 
		_transform = _transform.multiply( m ); 
		$.send( { "cmd":"translate", "args":[x,y] } );
	}

	function scale( x, y ) {
		if( typeof(y) == "undefined" ) y = x;
		var m = $M( [
			[ x, 0, 0 ], 
			[ 0, y, 0 ], 
			[ 0, 0, 1 ]
		] ); 
		_transform = _transform.multiply( m ); 
		$.send( { "cmd":"scale", "args":[x,y] } );
	}

	function rotate( a ) {
		var c = Math.cos( a )
		var s = Math.sin( a )
		var m = $M( [
			[ c,-s, 0 ], 
			[ s, c, 0 ], 
			[ 0, 0, 1 ]
		] ); 
		_transform = _transform.multiply( m ); 
		$.send( { "cmd":"rotate", "args":[a] } );
	}

	function project( x, y ) {
		var o = _transform.multiply( $V([x,y,1]) )
		return { x:o.elements[0], y:o.elements[1] }
	}

	function unproject( x, y ) {
		var inv = _transform.inverse();
		var o = inv.multiply( $V([x,y,1]) )
		return { x:o.elements[0], y:o.elements[1] }
	}

	function pushState() {
		$.send( { "cmd":"push" } );
	}

	function popState() {
		$.send( { "cmd":"pop" } );
	}

}




