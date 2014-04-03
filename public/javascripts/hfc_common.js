
function commonSetupElements() {
	$(".closeIcon").hover(
		function() {
			$(this).attr( "src", "/images/tabclose_with_circle.png" );
		},
		function() {
			$(this).attr( "src", "/images/tabclose.png" );
		}
	);
}

function setCookie( cookieName, value ) {
	var exdate = new Date();
	exdate.setFullYear( exdate.getFullYear() + 10 );
	document.cookie = cookieName + "=" + escape(value) + ";expires=" + exdate.toGMTString() + ";path=/";
}

function getCookie( cookieName ) {
	if( document.cookie.length > 0 ) {
		cookieStart = document.cookie.indexOf( cookieName + "=" );
		if( cookieStart != -1 ) {
			cookieStart = cookieStart + cookieName.length + 1;
			cookieEnd = document.cookie.indexOf( ";", cookieStart );
			if( cookieEnd==-1 ) {
				cookieEnd = document.cookie.length;
			}
			return unescape( document.cookie.substring(cookieStart,cookieEnd) );
		}
	}
	return "";
}

function delCookie( name ) {
	document.cookie = name + '=; expires=Thu, 01-Jan-70 00:00:01 GMT;';
}