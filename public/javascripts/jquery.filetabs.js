// Written by ZBS.

(function($){
	$.widget("ui.filetabs", {
		$tabs: [],
		$table: 0,
		_counter: 1,

		_init: function() {
			var $obj = $(this.element);

			// ENUMERATE the names
			var names = [];

			$obj.children().each( function() {
				names.push( $(this).html() );
			});

			// CREATE the table
			var tab = "<table class='filetabsTable' cellpadding='0' cellspacing='0'><tr>"
			tab += "<td id='fillerCol' class='filetab-fillertab'></td></tr></table>"
			$obj.html( tab );
			this.$table = $("table",$obj);

			// ADD the tabs
			for( var i=0; i<names.length; i++ ) {
				alert( "1)" + i );
				alert( "2)" + names[i] );
				this.add( names[i] );
			}
		},

		add: function( label ) {
			var self = this;
			var $obj = $(this.element);
			var tabId = this._counter;
			this._counter++;

			$("<td id='tabId-"+tabId+"' tabId='"+tabId+"' class='filetab-unselected'>"+label+"</td>")
				.insertBefore( $( "td:first", $obj ) )
			;

			this.$tabs[tabId] = $("#tabId-"+tabId,$obj);
			this.$tabs[tabId].click( function(event) {
				self.select( tabId );
			});

			return tabId;
		},

		remove: function( tabId ) {
			$("#tabId-"+tabId).remove();
		},

		select: function( tabId ) {
			var $obj = this.$tabs[tabId];

			if( $obj.hasClass( "filetab-unselected" ) ) {
				for( var i in this.$tabs ) {
					if( this.$tabs.hasOwnProperty(i) ) {
						this.$tabs[i].removeClass( "filetab-selected" );
						this.$tabs[i].addClass( "filetab-unselected" );
					}
				}

				$obj.addClass( "filetab-selected" );
				$obj.trigger( "filetabshow", [$obj, tabId] )
			}
		},

		setName: function( tabId, name ) {
			var $obj = this.$tabs[tabId];
			$obj.html( name );
		},

		getTabId: function() {
			for( var i in this.$tabs ) {
				if( this.$tabs.hasOwnProperty(i) ) {
					if( this.$tabs[i].hasClass("filetab-selected") ) {
						return this.$tabs[i].attr( "tabId" );
					}
				}
			}
		},

		length: function() {
			return this.$tabs.length;
		}
	});

	$.extend($.ui.filetabs, {
		version: '1.7.2',
		getter: 'length add getTabId',
		defaults: {}
	});


})(jQuery);
