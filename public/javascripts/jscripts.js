// JavaScript Document
dojo.require("dojo.widget.Dialog");
dojo.require("dojo.widget.Button");
dojo.require("dojo.widget.Tooltip");

/**
 * teste only
 */

function detect_open_id(where,to_disable_field,label) {
	text = where.value;
	upw = $(to_disable_field);
	upwLabel = $(label);
	if ( (text.toLowerCase().indexOf("http://") == 0 ) || (text.toLowerCase().indexOf("https://") == 0)) {
		upwLabel.addClassName("disabled");	
		upw.disabled = "disabled"
	} else {
		upwLabel.removeClassName("disabled");
		//upw.show();
		upw.disabled = ""
	}
}
function start_searching() {
	search.searching();
}

var search = {
	
	do_keydown:function(event) {

		if (event != null) {
            var key = event.which || event.keyCode;
			
			if (key == 13 ) {
				
				this.searching();
			}
		}
	},
	on_blur:function() {
		return;
		/*txt_search = $('txt_search');
		if (txt_search.value.strip() == "" ) {
			txt_search.value = "pesquisar";
		}*/

	},
	on_focus:function() {
		
		txt_search = $('txt_search');
		if (txt_search.value=="pesquisar" ) {
			txt_search.value = "";
		}
	},
	searching:function() {
		search_keywords = $('search_keywords');
		txt_search = $('txt_search');
		if (txt_search.value.strip() == "" ) {
			txt_search.focus();
			return;
		}
		search_keywords.value = txt_search.value;
		form_search = $('form_search');
		form_search.submit();
		//alert(search_keywords.value);
	}
	
}

// Set up a windows observer, check ou debug window to get messages
 var wndObserver = {
    onDestroy: function(eventName, win) {
		if (win == post_mailer.getOpenedWindow() ) {
			el = $('email_link_'+post_mailer.getId());
			//new Effect.Fade(el);
			//window.setTimeout('Element.remove(el)',700);
			Element.removeClassName(el,"active_with_inlinewindow");
			post_mailer.closeSuggestionWnd();
	    	//el = $('inline_container_wrapper_'+post_mailer.getId());
			//window.setTimeout('Element.remove(el)',100);
    	}
	}
  }
  
Windows.addObserver(wndObserver);

var emails_suggestions = {
	emails:new Array(),
	
	contacts:null,
	
	setContacts:function(contacts) {
		this.contacts = contacts;
		
	},
	
	setEmail:function(email) {
		
		this.emails.push(email);
		
	},
	getEmails:function(startingPattern) {
		
		suggestions = new Array();
		active_suggestions = new Array()
		startingPattern = startingPattern.strip();
		if (startingPattern == "" ) {
			return suggestions;
		}
		this.contacts.each(function(pair) {
			//alert(pair.value.toLowerCase());
			//alert(startingPattern.toLowerCase());
			
			if ( pair.value.toLowerCase().indexOf(startingPattern.toLowerCase()) == 0 ) {
				//alert("adding ");
				suggestions.push("<div><a onclick='post_mailer.addSuggestedEmail()' onmouseover='post_mailer.activateSuggestionOption(this)' id='"+pair.key+"' class='suggestion_link' href='javascript:void(0)'>"+pair.value+"</a></div>");	
				active_suggestions.push(pair.key);
			}
				
		});
		
		return [suggestions,active_suggestions]; 
	}
	
	
};

var post_mailer = {
	opened_window:null,
	email_list_auto_search_win:null,
	id:null,
	active_suggestions:null,
	active_sugestion:null,
	text_area:null,
	activeSelectionCounter:0,
	getId:function() {
		return this.id;
	},
	clearEmailValue:function() {
		email_value = $('my_email');
		if (email_value.value == "insere o teu email") {
			email_value.value = "";
		}
	},
	onLostFocusEmailValue:function() {
		email_value = $('my_email');
		if (email_value.value.strip() == "") {
			email_value.value = "insere o teu email";
			
		} else {
			if (!this.isEmailValid(email_value.value.strip())) {
				
				this.markInvalidEmail();
			} else {
				this.unMarkInvalidEmail();
				emails_value = $('email_content').value.strip()
				if ( emails_value != "" ) {
					$('send_email_button').disabled = "";
				}
			}
		}
		
	},
	unMarkInvalidEmail:function() {
		email_txt = $('my_email');
		email_txt.style.border="solid 1px #cccccc";
	},
	markInvalidEmail:function() {
		email_txt = $('my_email');
		email_txt.style.border="solid 1px #ff0000";
	},
	isEmailValid:function(email) {
		///^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
		if (email.sub(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,"")=="") {
			return true;	
		}
		return false;
		
	},
	showEmaillingWaiting:function() {
		$('inline_container_content').innerHTML = "<img src='/images/flower-blue.gif'/> A enviar o(s) email(s)";
	},
	completedEmailling:function() {
		//$('inline_container_content').innerHTML = "Os emails foram enviados com sucesso!<br/><input id=\"close_\" type=\"button\" value=\"Ok\" title=\"ok\" onclick=\"post_mailer.closeWindow()\"/> ";
		
	},
	addSuggestedEmail:function() {
		if (this.active_sugestion == null) {
			return;
		}
		//get the element selected
		selectedElement = $(this.active_sugestion);
		
		start_index = 0;
		this.text_area = $('email_content');	
		if ( this.text_area.selectionStart ) {
			//get 
			start_index = this.text_area.selectionStart;

		} else {
			start_index = this.text_area.value.length;
		}
		
		
		//if have any comma
		lastCommaIndex = this.text_area.value.lastIndexOf(",");
		//alert(lastCommaIndex);
		//this.text_area.value += selectedElement.innerHTML+", ";
		if ( lastCommaIndex > -1 ) {
//			this.text_area.value += this.text_area.value.substring(lastCommaIndex, this.text_area.value.length ) + selectedElement.innerHTML+", ";
			this.text_area.value = this.text_area.value.substring(0,lastCommaIndex+2 ) + selectedElement.innerHTML+", ";
		} else {
			this.text_area.value ="";
			this.text_area.value = selectedElement.innerHTML+", ";
			
		}
		//hack for opera
		//if ( this.text_area.selectionStart ) { 
		//	this.text_area.selectionEnd =  this.text_area.value.length;
		//}
		
		this.closeSuggestionWnd();
		this.active_sugestion = null;
		this.activeSelectionCounter = 0;
		this.text_area.focus();
		
	},
	activateSuggestionOption:function(what) {
		if (this.active_sugestion!= null ) {
			Element.removeClassName($(this.active_sugestion),"suggestion_link_hover"); 
		}
		this.active_sugestion = what.id;
		Element.addClassName($(this.active_sugestion),"suggestion_link_hover")
		this.activeSelectionCounter = 0;
		
	},
	moveSelectionDown:function() {
		//get current selection
		if (this.active_suggestions == null) {
			return;
		}
		if ( this.activeSelectionCounter < this.active_suggestions.length-1) {
			active_element_in_list = $(this.active_suggestions[this.activeSelectionCounter]);
			
			Element.removeClassName(active_element_in_list,"suggestion_link_hover");
			this.activeSelectionCounter++;
			active_element_in_list = $(this.active_suggestions[this.activeSelectionCounter]);
			Element.addClassName(active_element_in_list,"suggestion_link_hover");
			this.active_sugestion = active_element_in_list;
			
		}

	},
	moveSelectionUp:function() {
		//get current selection
		if (this.active_suggestions == null) {
			return;
		}
		if ( this.activeSelectionCounter > 0 ) {
			active_element_in_list = $(this.active_suggestions[this.activeSelectionCounter]);
			
			Element.removeClassName(active_element_in_list,"suggestion_link_hover");
			this.activeSelectionCounter--;
			active_element_in_list = $(this.active_suggestions[this.activeSelectionCounter]);
			Element.addClassName(active_element_in_list,"suggestion_link_hover");
			this.active_sugestion = active_element_in_list;
			
		}

	},

	showEmails:function(event,arg) {
		
		if (event != null) {
            var key = event.which || event.keyCode;
			
			if (key == 13 ) {
				this.addSuggestedEmail();
				return true;
			}
			if (key == 40 ) {
				if ( this.email_list_auto_search_win != null ) {
					this.moveSelectionDown();
					return;
				}
			}

			if (key == 38 ) {
				if ( this.email_list_auto_search_win != null ) {
					this.moveSelectionUp();
					return;
				}
			}
		}
		//get the last word in arg value
		val_array = arg.value.split(",");
		
		val = val_array[val_array.length-1]
		
		//get all emails starting with val
		suggestions = emails_suggestions.getEmails(val)[this.activeSelectionCounter];
		this.active_suggestions = emails_suggestions.getEmails(val)[1];
		html = "";
		for (var i=0; i< suggestions.length; i++) {
			//create html
			//alert(suggestions[i]);
			html +=suggestions[i];
		}
		
		if (html.length >0) {
		//if window is opened
			if (this.email_list_auto_search_win == null) {
				this.openSuggestionWnd();
			} 
			this.updateSuggestionWindowContent(html);
			//update first position
			first_element_in_list = $(this.active_suggestions[0]);
			Element.addClassName(first_element_in_list,"suggestion_link_hover");
			this.active_sugestion = first_element_in_list;
			//verify if there's any email starting with
		} else {
			
			if (this.email_list_auto_search_win != null) {
				this.closeSuggestionWnd();
			}
			//this.updateSuggestionWindowContent(html); 
	 
		}
		my_email = $('my_email').value.strip();
		
		if ( arg.value.strip() != "" && this.isEmailValid(my_email)) {
			$('send_email_button').disabled = "";
		} else {
			$('send_email_button').disabled = "disabled";
		}
	},
	validateWhenNotLogged:function(arg) {
		my_email = $('my_email').value.strip();
		if ( arg.value.strip() != "" && this.isEmailValid(my_email) ) {
			
			$('send_email_button').disabled = "";
		} else {
			$('send_email_button').disabled = "disabled";
			
		}
	},
	updateSuggestionWindowContent:function(content) {
		
		el = $('email_list_container');
		el.innerHTML = content;
	},
	
	closeSuggestionWnd:function() {
		if (this.email_list_auto_search_win != null ) {
			this.email_list_auto_search_win.close();
			this.email_list_auto_search_win = null;
			this.active_suggestions = null;
			this.activeSelectionCounter = 0;
		}
	},
	openSuggestionWnd:function() {
		el = $('autosearch_email');
		//Element.toggle(el);
		win2 = new Window({ className: "default",title: "", width:300, height:500, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false,draggable:false,showEffect: Element.show,hideEffect: Element.hide}); 
		win2.setHTMLContent("<div id='email_list_container'></div>");
		win2.show();
		win_o_ = $(win2.getId());
		
		Position.clone(el,win_o_,{offsetTop:-16,offsetLeft:0});
		this.email_list_auto_search_win = win2;	
	},
	expandWindow:function(ln) {
		//alert(ln.innerHTML);
		if (ln.innerHTML.indexOf("sel")>-1) {
			ln.innerHTML = "fechar >>";
			
			this.opened_window.setSize(400,400);
			newEl = $('select_email_recipients_list');
			
			new Effect.Appear(newEl);
		} else {
			new Element.hide(newEl);
			ln.innerHTML = "seleccionar &gt;&gt;";
			this.opened_window.setSize(400,120);
			
		}
	},
	closeWindow:function() {
		if ( this.email_list_auto_search_win != null ) {
			this.email_list_auto_search_win.close();
		}
		this.opened_window.close();	
		//alert("closing")
		el = $('email_link_'+this.id);
		//new Effect.Fade(el);
		//window.setTimeout('Element.remove(el)',700);
		Element.removeClassName(el,"active_with_inlinewindow");
		//Element.remove($('email_content'));
	},
	
	getOpenedWindow:function() {
		return this.opened_window;
	},
//	close_window:function(id) {
		
//		el = $('email_link_'+id);
		//new Effect.Fade(el);
		//window.setTimeout('Element.remove(el)',700);
//		Element.removeClassName(el,"active");
		
//	},
	
	send:function(id,parent,title,ajax_url) {
		//Create a div
		this.id = id;
		new_div = "<div class='inline_container_wrapper' style='display:none' id='inline_container_wrapper_"+id+"'><div class='title'>"+title+"</div></div>";
		
		//new Insertion.After($('emailer_container_placeholder_'+id),new_div);
		
		Element.addClassName(parent,"active_with_inlinewindow");
		child_div = $('inline_container_wrapper_'+id);

		//new Effect.Appear(child_div);
		
		//Position.clone(parent,child_div);
		
		
		win = new Window({ className: "alphacube",title: "", width:450, height:180, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false,draggable:false,showEffect: Element.show,hideEffect: Element.hide}); 

		
		win.setHTMLContent("<div id='inline_container_content'><img src='/images/flower-blue.gif'/></div>");
		//win.setHTMLContent("<img src='/images/flower-blue.gif'/>");

		win.show(true);
		this.opened_window = win;
		//win.setCloseCallBack(post_mailer.on_close());
		
		win_o = $(win.getId());
		Position.clone(parent,win_o,{offsetTop:16,offsetLeft:1});
		
		
		
		new Ajax.Request(ajax_url, {asynchronous:true, evalScripts:true, 
			onComplete:function(request){hideWaiting()}, //change this 
			onLoading:function(request){showWaiting()}}); //change this 
			return false;
		
	}
}

var last_click_opened = false;
var active_menu = null;
var drop_menu = {
	
	//last_click_opened:false,
	open_drop_menu: function(menu_name, parent) {
		el = $(menu_name);
		
        el.style.height = 'auto';
       
		Position.clone(parent,el);
		
		
		new Effect.toggle(el);
		active_menu = el;
		//now monitor for any click in the window
		last_click_opened = true;
		//alert(last_click_opened);
		Event.observe(window, 'click', drop_menu.close_any_opened_menu);
		
	},
	
	close_any_opened_menu:function() {
		//alert(last_click_opened);
		//alert(this.active_menu);
		if ( last_click_opened == true ) {
			last_click_opened = false;
		} else {
			
			if (active_menu != null ) {
				//alert("her");
				new Effect.toggle(active_menu);	
				last_click_opened = false;
				Event.stopObserving(window, 'click', drop_menu.close_any_opened_menu);
			}
		}
	}
}

var window_function = {
  
  do_mousemove: function(event) {
  
	
	mouse_trail = $('mouse_trail');
	mouse_trail.show();
	
	//yOffset=window.pageYOffset;
    //xOffset=window.pageXOffset;

	yOffset=Event.pointerY(event);
    xOffset=Event.pointerX(event);
	
    mouse_trail.style.top = yOffset+"px";
    mouse_trail.style.left = xOffset+"px";

	
	
  }
};

window_function.bfx = window_function.do_mousemove.bindAsEventListener(window_function);




//Event.stopObserving(window, 'mousemove', window_function.bfx);






var waitDialog;

function init(e) {
    waitDialog = dojo.widget.byId("server_processing_dialog_div");	
}

dojo.addOnLoad(init);


function showWaiting(event) {
	


	try {
		
		
		mouse_trail = $('mouse_trail');
		mouse_trail.show();
	}catch(e) { 
		//IE Sucx;
	}
	
	Event.observe(window, 'mousemove', window_function.bfx);
	
		
    //$('server_processing_dialog_div2').show();
    
    //yOffset=window.pageYOffset;
    //xOffset=window.pageXOffset;
    //$('server_processing_dialog_div2').style.top = yOffset+"px";
    //$('server_processing_dialog_div2').style.left = xOffset+"px";
    
    
    //waitDialog.show();
}

function hideWaiting() {
	
	
    //$('server_processing_dialog_div2').hide();
    //waitDialog.hide();
	Event.stopObserving(window, 'mousemove', window_function.bfx);
	try {
		mouse_trail = $('mouse_trail');
		mouse_trail.hide();
	}catch(e) { 
		//IE Sucx;
	}
}


function alert_you_voted_already() {
	
		win = new Window({ className: "alphacube",title: "<span class=\"warn\">Info</span>", width:440, height:100, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false}); 
		//win = new Window({ className: "alphacube",title: "Escolher utilizadores", width:440, height:450, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false}); 
		
		win.setHTMLContent("Ja votas-te neste link");
        win.showCenter(true);
		//Dialog.info("Ja votas-te neste link <br/><div class='small_close'><a href=\"javascript:Dialog.closeInfo()\">fechar</a></div>", {windowParameters: {className: "alphacube",closable: true,title: "Escolher utilizadores", width:400}})
}


function show_alert(msg) {
		win = new Window({ className: "alphacube",title: "<span class=\"info\">Info</span>", width:440, height:100, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false}); 
		win.setHTMLContent(msg);
		win.showCenter(true);
		//win.HTMLContent(msg);
		
    //Dialog.info(msg+"<br/><div class='small_close'><a href=\"javascript:Dialog.closeInfo()\">fechar</a></div>", {windowParameters: {className: "alphacube",closable: true, width:400}})
}

function show_logon_tooltip(msg,register,login) {
	
	win = new Window({ className: "alphacube",title: "<span class=\"forbidden\">Info</span>", width:440, height:100, maximizable:false,minimizable:false, destroyOnClose: true, recenterAuto:false}); 
		
	win.setHTMLContent(msg+"<br/> Faz <a href=\""+login+"\">login</a> ou <a href=\""+register+"\">regista-ta</a> caso ainda n&atilde;o o tenhas feito.");
	
	win.showCenter(true);
		
    //Dialog.info(msg+"<br/> Faz <a href=\""+login+"\">login</a> ou <a href=\""+register+"\">regista-ta</a> caso ainda n&atilde;o o tenhas feito. <br/><div class='small_close'><a href=\"javascript:Dialog.closeInfo()\">fechar</a></div>", {windowParameters: {className: "alphacube",closable: true, width:400}})
}

function hide_answer(div) {
    new Effect.toggle( $('comment_answer_bottom_'+div));
    new Effect.toggle( $('comment_answer_content_'+div));
        

    if ($('comment_answer_content_show_hide_text_'+div).innerHTML.indexOf("Ver")>-1) {
        $('comment_answer_content_show_hide_text_'+div).innerHTML = "Esconder resposta";
    } else {
        $('comment_answer_content_show_hide_text_'+div).innerHTML = "Ver resposta";
    }

}
function show_answers(div){
   
    new Effect.toggle( $('comment_answers_for_'+div));
    if ($('show_answers_link_text_'+div).innerHTML.indexOf("Esconder")>-1) {        
        $('show_answers_link_text_'+div).innerHTML = "Mostrar respostas";
       
    } else {
        $('show_answers_link_text_'+div).innerHTML = "Esconder respostas";
    
    }     
}
function hide_comment(div) {
    new Effect.toggle( $('comment_bottom_'+div));
    new Effect.toggle( $('comment_content_'+div));
    new Effect.toggle( $('comment_answers_for_'+div));
    
    var hiding = false;
    if ($('comment_content_show_hide_text_'+div).innerHTML.indexOf("Ver")>-1) {        
        $('comment_content_show_hide_text_'+div).innerHTML = "Esconder coment&aacute;rio";
    } else {
        $('comment_content_show_hide_text_'+div).innerHTML = "Ver coment&aacute;rio";
        hiding = true
    }
    //find all sub elements having id=comment_answer_boby_xxx
   
   /* childs = Element.siblings('comment_content_'+div);
    if (childs  != null) {
    
        for (var i=0; i< childs.size();i++)  {
            id = childs[i].id;
            
            if ( id!= null) {

                if (id.indexOf('comment_answer_boby_') > -1) {
                    if ( hiding  == true ) {
                        
                        //alert("hiding");
                        if ( $(id).visible() == true) {
                            //alert("is visible");
                            new Effect.toggle( $(id) );
                        } else {
                            //alert("is not visible");
                        }
                    } else {
                            //alert("showing");
                          if ( !$(id).visible())  {
                            new Effect.toggle( $(id));
                            //alert("is visible")
                        }
                    }
                 }
            }
       }
    }
   */ 
       
}

function updatePhoto(newUrl) {
    
    $('user_profile_photo').style.background = "url('"+newUrl+"') no-repeat";
}

  function show_hide_side_container(name) {
            
            if ($(name).visible()) {
                $(name+'-title').className = 'expandable-title-colapsed';
                new Effect.Fade($(name));
            } else {
                new Effect.Appear($(name));
                $(name+'-title').className = 'expandable-title-expanded';
            }
            
            
        }           


var active_timeout = null;
var active_helper_id = null;
function mark_for_close(id) {

	if ( active_timeout == null ) {
		active_timeout = window.setTimeout(close_helper,500);
		active_helper_id = id;
	}
}


function close_helper() {
	
	helper_container = $(active_helper_id);
	helper_container.hide();
	//delete please
	//
	
	Element.remove(helper_container);
	
	if ( active_timeout != null ) {
		window.clearTimeout(active_timeout);
		active_timeout = null;
		active_helper_id = null;
	}
	
}
function close_help_wnd(wnf_id) {
	
	helper_container = $(wnf_id);
	helper_container.hide();
	//delete please
	Element.remove(helper_container);
	active_helper_id = null;
}

function keep_helper_alive(id) {
	
	if ( active_timeout != null ) {
		window.clearTimeout(active_timeout);
		active_timeout = null;
	}	
	
}

function kill_helper(id) {
	if ( active_timeout == null ) {
		active_timeout = window.setTimeout(close_helper,250);
		active_helper_id = id;
	}
	
}

function open_helper(el, id,title,content_url) {
	
	if ( active_timeout != null ) {
		window.clearTimeout(active_timeout);
		active_timeout = null;
		return;
	}
		
	active_helper_id = id;
	html = "<div onmouseout=\"kill_helper('"+id+"')\" onmouseover=\"keep_helper_alive('"+id+"')\" id="+id+" class='inline_help_container' style=\"display:none\"><div class='inside'><div class='inline_helper_title'>"+title+"</div><div class='close'><a href=\"javascript:void(0)\" onclick=\"close_help_wnd('"+id+"')\">fechar</a></div><div class=\"inline_div_content_helper\" id=\"_idiv_"+id+"\"></div></div></div>"
	
	
	new Ajax.Request("/helpers/render_helper?page="+content_url+"&id="+id, {asynchronous:true, evalScripts:true, 
			onComplete:function(request){hideWaiting()}, //change this 
			onLoading:function(request){showWaiting()}}); //change this 
	

	//ok, create a div element 
	new Insertion.After(el,html);
	
	//get the helper window
	helper_container = $(id);
	//alert(helper_container);
	//helper_container.show();
	
	Position.clone(el,helper_container,{offsetTop:15,offsetLeft:4})
	helper_container.show();
	
	
}