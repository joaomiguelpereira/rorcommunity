/**
 * @author joao
 */
var selected_rows = new Array(); 
var win = null;
//tantos hacks, tanta merda, ate ja me perco



function close_dialog() {
	if (win) {
		win.close();
		if (feed_summary.selected_users_in_list == null || feed_summary.selected_users_in_list.length == 0 ) {
			//users_selection.use_all_users
			if ( last_selected_user_filter=="all" ) {
					//alert("have to selecte teh all");
					users_selection.use_all_users();
					swap_users($('show_users_all'));
			}
			if ( last_selected_user_filter=="network" ) {
					//alert("have to selecte teh all");
					users_selection.use_my_network_users();
					swap_users($('show_users_network'));
			}

			
		}
		//let'see what in the box
		
	}
}	

function open_user_selection_dialog() {
	
	//open a window in center of the window
	
	showWaiting();
	
	
	win = new Window({ className: "alphacube",title: "<span class=\"info\">Escolher utilizadores</span>", width:440, height:450, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false}); 
	
	win.setAjaxContent("/user/show_list_in_dialog", "", true, true);
	
	window.setTimeout("do_dialog_init()", 3000);
		
}

function do_dialog_init() {

	if ( feed_summary.get_selected_users() != null) {
		
		for (var i= 0; i< feed_summary.get_selected_users().length; i++) {
			do_auto_select_by_name(feed_summary.get_selected_users()[i]);	
		}
		
		if ( feed_summary.get_selected_users().length == 0 ) {
			$('rss_channel_use_groups').value = "";
		}

	} else {
		$('rss_channel_use_groups').value = "";
	}
	
	hideWaiting();
}
function do_auto_select_by_name(name) {
	//get the row with name=name
	 
	parent = $('user_list_container');
	childs = Element.getElementsByClassName(parent,'table_row');
	for (var i=0; i<childs.length; i++) {
		ul_child = Element.getElementsBySelector(childs[i],"ul");
		if (ul_child[0]) {
			//get the the first li
			li_child = Element.getElementsBySelector(ul_child[0],"li");
			if (li_child[0]) {
				a_child = Element.getElementsBySelector(li_child[0],"a");
				if ( a_child[0] ){
					if ( a_child[0].innerHTML == name ) {
						//clicked_table_row(ul_child[0], false);
						toggle_row_selected(ul_child[0]);
						return;
					}			
				}
			}
		}
		
				
	}
	
	
	//toggle_row_selected(row);
	
		
}
/**
 * this is hacked, must dinamically updatye all with a loop over all elements
 * @param {Object} row
 */
function toggle_row_selected(row) {

	
	
	child_elements = Element.getElementsByClassName(row,'table_cell');
	
	Element.toggleClassName(child_elements[0],'checked');
	Element.toggleClassName(child_elements[1],'checked_no_img');
	Element.toggleClassName(child_elements[2],'checked_no_img');
	Element.toggleClassName(child_elements[3],'checked_no_img');
	Element.toggleClassName(child_elements[4],'checked_no_img');
	
	
	return child_elements[0].getElementsBySelector('a')[0].innerHTML.strip();
	
	
		
	
}

function remove_word_in_text(word) {
	
	summary_box.update_user_names();		
	element_value = $('rss_channel_use_groups').value;
	
	var reg = new RegExp(word+" ","i");
    temp = element_value.sub(reg,function(match){return ''});
            
	$('rss_channel_use_groups').value = temp;
	summary_box.update_user_names();
	feed_summary.remove_selected_user(word);
}


function add_word_in_text(word) {
	
	//if already exists, then remove it
	
	
	element_value = $('rss_channel_use_groups').value;
	var reg = new RegExp(word+" ","i");
	if ( element_value.search(reg) > -1 ) {
		remove_word_in_text(word);
		//alert("removing instead");
		return;
	}
	
	//alert("Adding: "+word);
	$('rss_channel_use_groups').value = element_value + word+" ";
	summary_box.update_user_names();
	//update also the summary 
	feed_summary.add_selected_user(word);
	
	
}

var summary_box = {
	update_user_names: function() {
		
		el = $('summary_users');
		//get the value from the text box
		//alert($('rss_channel_use_groups').value);
		values = $('rss_channel_use_groups').value.strip().split(" ");
		new_html = '';
		
		
		if (values.length >1) {
			new_html = ' dos utilizadores ';
		}
		

		if (values.length==1) {
			new_html = ' do utilizador ';
		}

		
		 
		for (var i=0; i<values.length; i++) {
		
			new_html +='<b>'+values[i]+'</b>';
			if (i != values.length-1) {
				new_html +=', ';
			}else {
				new_html +=' ';
			}
			
		}
		el.innerHTML = new_html;
	}	
	
}

function auto_select_rows(rows) {
	
	
	the_rows = rows.strip().split(";");
	
	for (var i=0; i<the_rows.length; i++) {
		
		if (selected_rows['table_row_'+the_rows[i] ] ) {
			//alert( selected_rows['table_row_'+the_rows[i]].id );
			elm = $(selected_rows['table_row_'+the_rows[i]].id);
			toggle_row_selected(elm);
			
		}
		
	}
	
}




var users_table = {

	selected_order:"",
	direction:"",
	page:"",
	filter:"all",
	filter_selected:null,
	timeout_id: null,
	
	/**
	 * Refactor this 
	 * @param {Object} page
	 */
	changePage :function(page) {
		this.page = page
		//alert('/user/change_list_page_in_dialog?page='+this.page+'&amp;order_by='+this.selected_order+'&amp;direction='+this.direction);
		///new Ajax.Request('/user/change_list_page_in_dialog?page='+this.page, {asynchronous:true, evalScripts:true, onComplete:function(request){hideWaiting()}, onLoading:function(request){showWaiting()}}); return false;
		new Ajax.Request('/user/change_list_page_in_dialog?page='+this.page+'&order_by='+this.selected_order+'&direction='+this.direction+'&filter='+this.filter, {asynchronous:true, evalScripts:true, onComplete:function(request){hideWaiting()}, onLoading:function(request){showWaiting()}}); return false;
		//new Ajax.Request('/user/change_list_page_in_dialog?page=1&order_by='+this.selected_order+'&direction='+this.direction+'&filter='+this.filter, {asynchronous:true, evalScripts:true, onComplete:function(request){hideWaiting()}, onLoading:function(request){showWaiting()}}); return false;
	},


	order_by: function(what) {
				//class="orderable_table_header_cell"
		
		option = what.innerHTML.strip();

		/**Refactor next**/
		
		if (option.indexOf("Rede") >-1 ) {
			
			//if previouly clicked
			if ( this.selected_order == "network") {
				//if previous down
				if (this.direction == "down") {
					Element.removeClassName($('cell_header_network'), 'orderable_table_header_cell_down');
					Element.addClassName($('cell_header_network'), 'orderable_table_header_cell_up');
					
					
					this.direction = "up";

				} else {
					Element.removeClassName($('cell_header_network'), 'orderable_table_header_cell_up');
					Element.addClassName($('cell_header_network'), 'orderable_table_header_cell_down');
					this.direction = "down";
					
				}	
			} else {
				Element.addClassName($('cell_header_network'), 'orderable_table_header_cell_down');
				this.selected_order = "network";
				this.direction = "down";
				

			}
			
			
		} else {
			Element.removeClassName($('cell_header_network'), 'orderable_table_header_cell_down');
			Element.removeClassName($('cell_header_network'), 'orderable_table_header_cell_up');			
		}
		/***********/		
						


	/**Refactor next**/
		
		if (option.indexOf("Membro") >-1 ) {
			
			//if previouly clicked
			if ( this.selected_order == "activated_at") {
				//if previous down
				if (this.direction == "down") {
					Element.removeClassName($('cell_header_date'), 'orderable_table_header_cell_down');
					Element.addClassName($('cell_header_date'), 'orderable_table_header_cell_up');
					
					
					this.direction = "up";

				} else {
					Element.removeClassName($('cell_header_date'), 'orderable_table_header_cell_up');
					Element.addClassName($('cell_header_date'), 'orderable_table_header_cell_down');
					this.direction = "down";
					
				}	
			} else {
				Element.addClassName($('cell_header_date'), 'orderable_table_header_cell_down');
				this.selected_order = "activated_at";
				this.direction = "down";
				

			}
			
			
		} else {
			Element.removeClassName($('cell_header_date'), 'orderable_table_header_cell_down');
			Element.removeClassName($('cell_header_date'), 'orderable_table_header_cell_up');			
		}
		/***********/		
		
		
	/**Refactor next**/
		
		if (option.indexOf("Rank") >-1 ) {
			
			//if previouly clicked
			if ( this.selected_order == "rank") {
				//if previous down
				if (this.direction == "down") {
					Element.removeClassName($('cell_header_rank'), 'orderable_table_header_cell_up');
					/**is swicth with the other*/
					Element.addClassName($('cell_header_rank'), 'orderable_table_header_cell_down');
					
					
					this.direction = "up";

				} else {
					Element.removeClassName($('cell_header_rank'), 'orderable_table_header_cell_down');
					Element.addClassName($('cell_header_rank'), 'orderable_table_header_cell_up');
					this.direction = "down";
					
				}	
			} else {
				Element.addClassName($('cell_header_rank'), 'orderable_table_header_cell_up');
				this.selected_order = "rank";
				this.direction = "down";
				

			}
			
			
		} else {
			Element.removeClassName($('cell_header_rank'), 'orderable_table_header_cell_down');
			Element.removeClassName($('cell_header_rank'), 'orderable_table_header_cell_up');			
		}
		/***********/		
						
		
		/**Refactor next**/
		
		if (option.indexOf("Nome") >-1 ) {
			
			//if previouly clicked
			if ( this.selected_order == "screen_name") {
				//if previous down
				if (this.direction == "down") {
					Element.removeClassName($('cell_header_name'), 'orderable_table_header_cell_down');
					Element.addClassName($('cell_header_name'), 'orderable_table_header_cell_up');
					
					
					this.direction = "up";

				} else {
					Element.removeClassName($('cell_header_name'), 'orderable_table_header_cell_up');
					Element.addClassName($('cell_header_name'), 'orderable_table_header_cell_down');
					this.direction = "down";
					
				}	
			} else {
				Element.addClassName($('cell_header_name'), 'orderable_table_header_cell_down');
				this.selected_order = "screen_name";
				this.direction = "down";
				

			}
			
			
		} else {
			Element.removeClassName($('cell_header_name'), 'orderable_table_header_cell_down');
			Element.removeClassName($('cell_header_name'), 'orderable_table_header_cell_up');			
		}
		/***********/		
		
		if (option.indexOf("Links") >-1 ) {
			
			//if previouly clicked
			if ( this.selected_order == "links") {
				//if previous down
				if (this.direction == "down") {
					Element.removeClassName($('cell_header_links'), 'orderable_table_header_cell_down');
					Element.addClassName($('cell_header_links'), 'orderable_table_header_cell_up');
					
					
					this.direction = "up";

				} else {
					Element.removeClassName($('cell_header_links'), 'orderable_table_header_cell_up');
					Element.addClassName($('cell_header_links'), 'orderable_table_header_cell_down');
					this.direction = "down";
					
				}	
			} else {
				Element.addClassName($('cell_header_links'), 'orderable_table_header_cell_down');
				this.selected_order = "links";
				this.direction = "down";
				

			}
			
		} else {
			
			Element.removeClassName($('cell_header_links'), 'orderable_table_header_cell_up');
			Element.removeClassName($('cell_header_links'), 'orderable_table_header_cell_down');
			
		}
		this.update_table();
		
	},
	/**recfactor this**/
	update_table : function() {
		
		//alert(this.direction);
		//alert(this.selected_order);
		//do a call 
		//alert('/user/change_list_page_in_dialog?page=1&order_by='+this.selected_order+'&direction='+this.direction+'&filter='+this.filter);
		
		new Ajax.Request('/user/change_list_page_in_dialog?page=1&order_by='+this.selected_order+'&direction='+this.direction+'&filter='+this.filter, {asynchronous:true, evalScripts:true, onComplete:function(request){hideWaiting()}, onLoading:function(request){showWaiting()}}); return false;
	},
	select_none: function() {
		parent_el = $('user_list_container');
		row_element = Element.getElementsByClassName(parent_el,'table_row');
		
		//autoselect
		for (var i=0; i< row_element.length; i++ ) {
			//get UL element
			rows = Element.getElementsBySelector(row_element[i],"ul");
			//alert(rows[0].id);
			//verify if its already selected
			if ( selected_rows[rows[0].id] ) {
				user_name = toggle_row_selected(rows[0]);
				selected_rows[rows[0].id] = null;
				remove_word_in_text(user_name);
			} 
			
		} //end for		
		
	},
	
	apply_filter: function(value_provider) {
		//set a timeout
		if (this.timeout_id)
			window.clearTimeout(this.timeout_id);
		//alert("2");
		//this.timeout_id = window.setTimeout("this.execute_filter()",2000);
		this.timeout_id = window.setTimeout(this.execute_filter,700);
		
	},
	execute_filter: function() {
		alert("doin auto filter");
		window.clearTimeout(this.timeout_id);
		this.timeout_id = null;
		
	},
	
	select_all: function() {
		//get all table_row element
		parent_el = $('user_list_container');
		row_element = Element.getElementsByClassName(parent_el,'table_row');
		
		//autoselect
		for (var i=0; i< row_element.length; i++ ) {
			//get UL element
			rows = Element.getElementsBySelector(row_element[i],"ul");
			//alert(rows[0].id);
			//verify if its already selected
			if ( !selected_rows[rows[0].id] ) {
				user_name = toggle_row_selected(rows[0]);
				selected_rows[rows[0].id] = rows[0];
				add_word_in_text(user_name);
			} 
			
		} //end for		
	},
	
	swap_filter: function(what) {
		
		if (this.filter_selected==null)
			this.filter_selected = $('table_extra_filter_all');
		
		if ( what.id.indexOf('all') >-1 ) {
			this.filter = "all";
			//add class name 
			
			Element.removeClassName(this.filter_selected,'selected');
			
			Element.addClassName(what,'selected');
			this.filter_selected = what;
					
		}
	if ( what.id.indexOf('network') >-1 ) {
			this.filter = "network";
			//add class name 
			
			Element.removeClassName(this.filter_selected,'selected');
			Element.addClassName(what,'selected');
			this.filter_selected = what;
					
		}

	this.update_table();
	
	}
}

/**
 * 
 * @param {Object} what
 */
function clicked_table_row(what, update_text) {
	
	user_name = toggle_row_selected(what);
	
	if ( selected_rows[what.id] ) {
		selected_rows[what.id] = null;

		remove_word_in_text(user_name);
	} else {
		
		selected_rows[what.id] = what;
		if ( update_text )
			add_word_in_text(user_name);
	}
	
	
	
	
	
	
}


 


/**
 * Its turns very slow in opera
 * @param {Object} what
 */
function flash_highlight_table_row(what) {
	
	//slooooow in opera	//to fix someday
	Element.toggleClassName(what,'selected');
	

}
