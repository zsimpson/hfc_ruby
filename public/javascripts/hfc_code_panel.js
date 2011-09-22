var codeMirrorFunction = null;
var codeMirrorStart = null;
var codeMirrorLoop = null;
var codeCurrentProgramName = "Un-named";
var codeCurrentProgramId = 0;
var codeCurrentProgramVersionNumber = 0;
var codeCurrentProgramVersionCount = 0;

var hfcRunner = HfcRunner;

$(document).ready( function() {

	$("#codeFunctionCodeDivDrag").mousedown( function(event) {
		$("body").mousemove( function(event) {
			var top = $("#codeFunctionCodeDiv").offset().top;
			$("#codeFunctionCodeDiv").css( "height", event.pageY - top );
			$("#codeFunctionEditor").css( "height", $("#codeFunctionCodeDiv").height() - $("#codeFunctionEditor").position().top );
			resize();
		});
		$("body").mouseup( function() {
			$(this).unbind( "mousemove" );
		});
	});
	
	$("#codeStartCodeDivDrag").mousedown( function(event) {
		$("body").mousemove( function(event) {
			var top = $("#codeStartCodeDiv").offset().top;
			$("#codeStartCodeDiv").css( "height", event.pageY - top );
			$("#codeStartEditor").css( "height", event.pageY - top - 30 );
			$(codeMirrorStart.getScrollerElement()).css( "height", event.pageY - top - 30 );
			resize();
		});
		$("body").mouseup( function() {
			$(this).unbind( "mousemove" );
		});
	});

	$("#codeLoopCodeDivDrag").mousedown( function(event) {
		var top = $("#codeLoopCodeDiv").offset().top;
		$("body").mousemove( function(event) {
			$("#codeLoopCodeDiv").css( "height", event.pageY - top );
			$("#codeLoopEditor").css( "height", event.pageY - top - 20 );
			$(codeMirrorLoop.getScrollerElement()).css( "height", event.pageY - top - 30 );
			resize();
		});
		$("body").mouseup( function() {
			$(this).unbind( "mousemove" );
		});
	});

	var codeMirrorOptions = {
		enterMode:"keep",
		tabMode:"shift",
		indentUnit:4,
		matchBrackets:true,
		mode:{name:"javascript"},
		lineNumbers:true,
		theme:"neat",
	}
	codeMirrorFunction = CodeMirror.fromTextArea( document.getElementById("codeFunctionEditor"), codeMirrorOptions );
	codeMirrorStart    = CodeMirror.fromTextArea( document.getElementById("codeStartEditor"   ), codeMirrorOptions );
	codeMirrorLoop     = CodeMirror.fromTextArea( document.getElementById("codeLoopEditor"    ), codeMirrorOptions );

	var startCode = getCookie( "startCode" );
	if( startCode )  {
		codeMirrorStart.setValue( startCode );
	}
	var loopCode = getCookie( "loopCode" );
	if( loopCode )  {
		codeMirrorLoop.setValue( loopCode );
	}

	hfcRunner.init({
		canvasId0: "codeMainCanvas0",
		canvasId1: "codeMainCanvas1",
		frameCallback: function(fps) {
			$("#codeFps").html( fps.toFixed(0) );
		},
		errorStateCallback: codeSetErrorState,
	}); 

	$(codeMirrorStart.getInputField()).keyup( function(e) { codeRestart() } );
	$(codeMirrorLoop .getInputField()).keyup( function(e) { codeRestart() } );

	var lastLoadedProgramId = getCookie( "lastLoadedProgramId" );
	if( lastLoadedProgramId ) {
		codeLoad( lastLoadedProgramId );
	}

});

$(window).resize( codeResize );

function codeSetErrorState( blockName, exceptMessage, exceptLine ) {
	var header = "";	
	if( blockName == "Start code" ) {
		header = exceptLine ? ("Line "+exceptLine+": ") : ""
		div = "codeStartCodeErrorState";
	}
	else if( blockName == "Loop code" ) {
		header = exceptLine ? ("Line "+exceptLine+": ") : ""
		div = "codeLoopCodeErrorState";
	}
	else {
		header = blockName + ": " + (exceptLine ? (" line "+exceptLine+": ") : "");
		div = "codeMasterErrorState";
	}

	if( exceptMessage ) {
		$("#"+div).html( header + exceptMessage );
	}
	else {
		$("#"+div).html( "" );
	}
}

function codeTabSelected() {
	codeResize();
}

var codeTwiddlers = {};
var codeTwiddlerChecks = {};

function codeSetVarFromTwiddler( varName ) {
	var startCode = codeMirrorStart.getValue();
	var lines = startCode.split( "\n" );
	for( var i in lines ) {
		var m = lines[i].match( "^(_\\S+)\\s*=\\s*(\\S+)" )
		if( m ) {
			for( var j in codeTwiddlers ) {
				if( j == m[1] ) {
					lines[i] = "" + m[1] + " = " + codeTwiddlers[j];
					break;
				}
			}
		}
	}
	var newStr = lines.join( "\n" );
	codeMirrorStart.setValue( newStr );
	if( $("#"+varName+"_restart").attr( "checked" ) ) {
		codeRestart();
	}
}

function codeRestart() {
	// PARSE for twiddlers
	$("#codeTwiddlers").html( "<tr><td><b>Name</b></td><td><b>Value</b></td></tr>" );
	$("#codeCreateATwiddlerNote").css( "display", "block" );
	codeTwiddlers = [];
	var startCode = codeMirrorStart.getValue();
	var lines = startCode.split( "\n" );
	var twiddlerCount = 0;
	for( var i in lines ) {
		var m = lines[i].match( "^(_\\S+)\\s*=\\s*(\\S+)" )
		if( m ) {
			$("#codeCreateATwiddlerNote").css( "display", "none" );
			codeTwiddlers[m[1]] = m[2];
			$("#codeTwiddlers").append( "<tr><td>"+m[1]+"</td><td><input class='twiddler' varName='"+m[1]+"' type='text' id='" + m[1] + "' value='"+m[2]+"'></td></tr>" );
			twiddlerCount++;
		}
	}
	if( twiddlerCount > 0 ) {
		$("#codeTwiddlers").prepend( "<tr><td colspan='2'>Click and drag mouse up and down on field to change value</td></tr>" );
	}
	else {
		$("#codeTwiddlers").html("");
	}
	
	// SETUP the twiddlers
	$(".twiddler").mousedown( function(event) {
		var startVal = Number( $(this).val() );
		startVal = Math.max( 0.001, startVal );
		var startY = Number( event.pageY );
		var varName = $(this).attr( "varName" );
		var deThis = this;
		$("body").mousemove( function(event) {
			var newVal = Number( startVal * Math.exp( (startY - event.pageY)/50 ) );
			newVal = newVal.toPrecision( 4 );
			$(deThis).val( newVal );
			codeTwiddlers[varName] = newVal;
			codeSetVarFromTwiddler( varName );
		});
		$("body").mouseup( function() {
			$(this).unbind( "mousemove" );
		});
	});

	$(".twiddler").change( function(event) {
		var varName = $(this).attr( "varName" );
		codeTwiddlers[varName] = $(this).val();
		codeSetVarFromTwiddler( varName );
	});
	
	$(".twiddlerRestartCheck").change( function(event) {
		codeTwiddlerChecks[ $(this).attr( "varName" ) ] = $(this).attr( "checked" ); 
	});
	
	// BUILD a list of all the code that's running and the currently bound globals
	var loopCode = codeMirrorLoop.getValue();
	var globalCode = "";//codeMirrorGlobal.getValue();
	var source = [ startCode, loopCode, globalCode ];
	for( i in globals ) {
		source.push( globals[i] );
	}

	// SEARCH all those sources for references to globals
	var matches = [];
	for( var i=0; i<source.length; i++ ) {
		var str = source[i];
		var regex = /(\$[a-zA-Z0-9_]+)/img;
		var match = regex.exec( str );
		while( match instanceof Array ) {
			matches.push( match );
			match = regex.exec( str );
		}
	}
	
	for( i in matches ) {
		codeBindGlobal( matches[i][1] );
	}

	hfcRunner.restart( codeMirrorStart.getValue(), codeMirrorLoop.getValue(), globals, codeTwiddlers );
}

function codeStop() {
	hfcRunner.stop();
}

function codeResize() {
	// ARRANGE all the divs
	var pageW = $(window).width();
	var pageH = $(window).height();
	var mcTop = $("#codeMainPanel").offset().top;
	var h = pageH - mcTop - 25;
	
	$("#codeMainPanel").css( "position", "relative" );
	$("#codeMainPanel").css( "width", "100%" );
	$("#codeMainPanel").css( "height", h );
	
	var mainW = $("#codeMainPanel").width() - 20;  // 20 for the scroll bar
	var spacing = 5;
	var col2W = 350;
	var col1W = mainW - col2W - spacing;
	var col1L = 0;
	var col2L = col1L + col1W + spacing;

	$("#codeMainCol1").css( "position", "absolute" );
	$("#codeMainCol1").css( "width", col1W );
	$("#codeMainCol1").css( "height", h );
	$("#codeMainCol1").css( "left", col1L );
	
	$("#codeMainCol2").css( "position", "absolute" );
	$("#codeMainCol2").css( "width", col2W );
	$("#codeMainCol2").css( "height", h );
	$("#codeMainCol2").css( "left", col2L );

	$(".codeEditor").css( "width", col1W - 6 ); // Not sure what's up with this exta 6 pixels.  Only seems nec. under chrome
}

function codeLoad( id, versionNumber ) {
	if( typeof(versionNumber) == "undefined" ) {
		versionNumber = -1;
	}
	$.get( "/programs/"+id, { version:versionNumber }, function(data) {
		codeHidePrograms();
	
		if( data.success ) {
			codeCurrentProgramIsNew = false;
			codeCurrentProgramName = data.name;
			codeCurrentProgramId = data.id;
			$("#codeCurrentProgramName").html( codeCurrentProgramName );
			codeMirrorStart.setValue( data.start_code ? data.start_code : "" );
			codeMirrorLoop.setValue( data.loop_code ? data.loop_code : "" );
			codeCurrentProgramVersionNumber = data.version;
			codeCurrentProgramVersionCount = data.version_count;
			$("#codeVersionNumber").html( (data.version+1) + " of " + data.version_count );
			setCookie( "lastLoadedProgramId", data.id );
			codeRestart();
		}
		else {
			alert( data.error );
		}
	});
}

function codeLoadPreviousVersion() {
	codeLoad( codeCurrentProgramId, codeCurrentProgramVersionNumber-1 )
}

function codeLoadNextVersion() {
	codeLoad( codeCurrentProgramId, codeCurrentProgramVersionNumber+1 )
}

function codeLoadLatestVersion() {
	codeLoad( codeCurrentProgramId )
}

function codeNew() {
	// CLEAR the editors
	codeMirrorFunction.setValue("");
	codeMirrorStart.setValue("");
	codeMirrorLoop.setValue("");
	codeCurrentProgramId = 0;
	codeCurrentProgramName = "Un-named";
	$("#codeCurrentProgramName").html( codeCurrentProgramName );
	codeCurrentProgramVersionNumber = 0;
	codeCurrentProgramVersionCount = 0;
	$("#codeVersionNumber").html( "" );
	codeStop();
}
	
function codeSave() {
	if( codeCurrentProgramName == "Un-named" ) {
		codeSaveAs();
	}
	else {
		$.ajax({
			type: "PUT",
			url: "/programs/"+codeCurrentProgramId,
			data:{name:codeCurrentProgramName, loop_code:codeMirrorLoop.getValue(), start_code:codeMirrorStart.getValue() },
			success:function(data) {
				if( data.success ) {
					codeCurrentProgramId = data.id;
					codeCurrentProgramName = data.name;
					$("#codeCurrentProgramName").html( codeCurrentProgramName );
					codeCurrentProgramVersionNumber = 0;
					codeCurrentProgramVersionCount = data.version_count;
					$("#codeVersionNumber").html( (data.version_count-codeCurrentProgramVersionNumber) + " of " + data.version_count );
				}
				else {
					alert( data.error );
					codeCurrentProgramName = "Un-named";
				}
			}
		});
	}
}

function codeSaveAs() {
	codeCurrentProgramId = 0;
	$("#codeSaveAsName").val( codeCurrentProgramName );
	$("#codeMainControlPanel").css( "display", "none" );
	$("#codeSaveAsControlPanel").css( "display", "block" );
}

function codeSaveAsOk() {
	$("#codeMainControlPanel").css( "display", "block" );
	$("#codeSaveAsControlPanel").css( "display", "none" );
	codeCurrentProgramName = $("#codeSaveAsName").val();
	codeSave();
}

function codeSaveAsCancel() {
	$("#codeMainControlPanel").css( "display", "block" );
	$("#codeSaveAsControlPanel").css( "display", "none" );
}

function codeLoginToSave() {
	setCookie( "startCode", codeMirrorStart.getValue() );
	setCookie( "loopCode", codeMirrorLoop.getValue() );
	document.location = "/login";
}

function codeShowPrograms() {
	$("#codeProgramsPanel").load( "/programs/programs_and_friends_panel", commonSetupElements );
	$("#codeProgramsPanel").css( "display", "block" );
	$("#codeProgramsControlPanel").css( "display", "block" );
	$("#codeMainPanel").css( "display", "none" );
	$("#codeMainControlPanel").css( "display", "none" );
}

function codeHidePrograms() {
	$("#codeProgramsPanel").css( "display", "none" );
	$("#codeProgramsControlPanel").css( "display", "none" );
	$("#codeMainPanel").css( "display", "block" );
	$("#codeMainControlPanel").css( "display", "block" );
}


function codeFriendAddByTextField() {
	$("#codeFriendsErrors").html( "" );
	var name = $("#codeFriendAddName").val();
	$.post( "/friends", {name:name}, function(data) {
		if( data.success ) {
			codeShowPrograms();
		}
		else {
			$("#codeFriendsErrors").html( data.error );
		}
	});
}

function codeFriendDeleteById( id ) {
	if( confirm( "Are you sure you want to un-friend this user?" ) ) {
		$.ajax({
			url: "/friends/"+id,
			type: "DELETE",
			success: function(data) {
				if( data.success ) {
					codeShowPrograms();
				}
				else {
					alert( data.error );
				}
			},
			error: function() {
				alert( "delete failed" );
			}
			
		});
	}
}

function codeDeleteById( programId ) {
	if( confirm( "Are you sure you want to delete this program?" ) ) {
		$.ajax({
			url: "/programs/"+programId,
			type: "DELETE",
			success: function(data) {
				if( data.success ) {
					codeShowPrograms();
				}
				else {
					alert( data.error );
				}
			},
			error: function() {
				alert( "delete failed" );
			}
		});
	}
}

function codeShowGlobals() {
	$("#codeGlobalsPanel").load( "/public_functions/list.html", commonSetupElements );
	$("#codeGlobalsPanel").css( "display", "block" );
	$("#codeGlobalsControlPanel").css( "display", "block" );
	$("#codeMainPanel").css( "display", "none" );
	$("#codeMainControlPanel").css( "display", "none" );
}

function codeHideGlobals() {
	$("#codeGlobalsPanel").css( "display", "none" );
	$("#codeGlobalsControlPanel").css( "display", "none" );
	$("#codeMainPanel").css( "display", "block" );
	$("#codeMainControlPanel").css( "display", "block" );
}

var globals = [];
var globalsLoad = [];
var globalsEditting = "";

function codeClearGlobals() {
	globals = [];
	globalsLoad = [];
	globalsEditting = "";
	//codeMirrorGlobals.setValue( "" );
}

function codeUpdateGlobalCode() {
	globals[ globalsEditting ] = codeMirrorGlobals.getValue();
}

function codeBindGlobal( name ) {
	if( ! globalsLoad[name] ) {
		globalsLoad[name] = true;
		$.get( "/public_functions/"+name, function(data) {
			if( data.success ) {
				globals[data.name] = data.name + " = " + data.code;
				codeRestart();
			}
		});
	}
}

