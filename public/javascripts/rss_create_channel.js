  //-----------
    
    var the_highlited_tags = new Array();

	var last_selected_user_filter = "all";
    
    
    var last_clicked_from_tag = false;
    
	
    
    //-------------------
    function update_autocomplet_div(new_props) {
        new_html = "";
        
        if ( new_props.length > 0 )
            new_html +="<span class=\"sugestion\">Sugest&atilde;o: </span>";
        
        for (var i = 0; i< new_props.length; i++ ) {

            
            new_html += '<a href="javascript:void(0)" onclick="autoCompleteTag(';
            new_html += '\''+new_props[i][1]+'\'';
            new_html += ')">';
            new_html += new_props[i][0];
            new_html += '</a>';
        }
        
        $('autocomplete').innerHTML = new_html;   
    }
    
    function autoCompleteTag(tag) {
        //remove from the text area last word
        
        el = $('rss_channel_filter_tags')
        new_text = el.value; 
        text_arrays = el.value.strip().split(" ");
        
        last_word = text_arrays[text_arrays.length-1]
        
        
        
        //var reg = new RegExp('\^'+last_word.toLowerCase(),"i");
        
        //el.value = new_text.substr(st,len);
        
        el.value = new_text.substr(0,new_text.length-last_word.length);
        
        //alert(last_word);
        //clear sugestions
        clear_sugestions();
        addTag(tag);
        
    }
    
    
    function clear_sugestions() {
        $('autocomplete').innerHTML = "";
    }
    
    function get_from_your_tags_matches(word,matches) {

        if (word==' ' || word=='') {
            return matches;
        }
        
        the_tags.each(function(pair) {
            var reg = new RegExp('\^'+word.toLowerCase(),"i");
            if ( pair.value.toLowerCase().search(reg) >=0 ) {
                //only if is not highlited
                if (!highlited(pair.key))
                    matches[matches.length] = [pair.value,pair.key.toString()];
             }     
          });
        return matches;
    
    }
    
    function highlited(the_tag) {
        tag = $(the_tag);
        if (tag.hasClassName('highlight_sel_tag'))
            return true;
        return false; 
    }
    
    function do_auto_search(el) {
        //look in the text for the last_word
        text_arrays = el.value.split(" ");
        last_word = text_arrays[text_arrays.length-1]
        
        var proposed_tags = new Array();
        
        proposed_tags = get_from_your_tags_matches(last_word,proposed_tags);
        
        update_autocomplet_div(proposed_tags);
        //synch
        update_summary_tags();
        synch_tags();
    }
    
    function update_summary_tags() {
        
        if ($('rss_channel_filter_tags').value.strip() == '') {
            $('tags_summary_name').innerHTML = "";
            $('tags_summary_tags').innerHTML = "";
            return;
        }   
        
        text_array = $('rss_channel_filter_tags').value.strip().split(" ");
        


        if ( text_array.length == 1 ) {
            $('tags_summary_name').innerHTML = "com a tag ";
        } else {
            $('tags_summary_name').innerHTML = "com as tags ";
        } 
        html = "";
        
        
        opVal = " ou ";
        tmp = $('tags_operator').value
        if ( tmp == "2")
            opVal = " e ";
            
            
        for (var i=0; i< text_array.length; i++ ) {
            html += "<b>"+text_array[i]+"</b>";
            
            if (i!= text_array.length-1 ) {
                html += "<span class=\"summary_tag_operator\">"+opVal+"</span>";
            }
        }
        
        $('tags_summary_tags').innerHTML = html; 
        
    }
    
    function synch_tags() {
        
        text_array = $('rss_channel_filter_tags').value.strip().split(" ");
        
        the_tags.each(function(pair) {
            was_hig = false;
            for (var i=0; i<text_array.length; i++) {
                
                if (pair.value.toLowerCase() == text_array[i].toLowerCase() ) { 
                    highlight_tag(pair.key);
                    was_hig = true;
                } else {
                    //unHighlight_tag(pair.key);
                }
                
             }
             if (!was_hig) {
                unHighlight_tag(pair.key);
                //do_auto_search($('rss_channel_filter_tags'));
             } 
                
              
       });
        
        
    }
    
    function update_array(array_text) {
        
        tem_text = $('rss_channel_filter_tags').value.strip();
        
        text_tags_array = tem_text.split(" ");
        
        for (var i=0; i<text_tags_array.length; i++) {
            
            the_tags.each(function(pair) {
            
                if (pair.value == text_tags_array[i]) 
                    highlight_tag(pair.key);
                    last_clicked_from_tag = true;
                    
                    //alert("pls highlight"+pair.value);    
            });
        }   
        $('rss_channel_filter_tags').focus();
    }

    function isInTextBox(text, newValue) {
    
        var text_box_array = text.split(' ');
        
        for (var i=0; i<text_box_array.length; i++) {
            if ( text_box_array[i].toLowerCase() == newValue.toLowerCase() ) {
                return true;
            }
        }
        
        return false;
    }
    
    
    function highlight_tag(tag_id) {
        $(tag_id).addClassName('highlight_sel_tag');    
    }

    function unHighlight_tag(tag_id) {
        $(tag_id).removeClassName('highlight_sel_tag');    
    }
    
    function addTag(tag_id) {
        last_clicked_from_tag = true;
        var text_area_text = '';
        text_area_text = $('rss_channel_filter_tags').value;
        
        //find it in the_tags
        if ( !isInTextBox(text_area_text, the_tags[tag_id]) ) {
        
            text_area_text = text_area_text.strip();
            if ( text_area_text != '' )
                text_area_text  +=' ';
                
            text_area_text += the_tags[tag_id];
            $('rss_channel_filter_tags').value = text_area_text+" ";
            highlight_tag(tag_id);
            synch_tags();
            
        } else {
            //removing tag text from text area
            
            var reg = new RegExp(the_tags[tag_id]+" ","i");
            temp = text_area_text.sub(reg,function(match){return ''});
            
            $('rss_channel_filter_tags').value = temp.strip()+" ";
            //synch_tags();
            unHighlight_tag(tag_id);
        }
        
        $('rss_channel_filter_tags').focus();
        update_summary_tags();
        
        
    }

    //-----------
    function reorder_tag_cloud_filter(name) {
        if ($('re_filter_all').hasClassName('selected')) 
            $('re_filter_all').removeClassName('selected')        
       
       if ( $('re_filter_network').hasClassName('selected'))
            $('re_filter_network').removeClassName('selected')
        
        el = $('re_filter_'+name);

        Element.addClassName(el,"selected");
        new Ajax.Request('/post/change_tag_cloud_order_new_channel?show='+name, {asynchronous:true, evalScripts:true, onComplete:function(request){hideWaiting()}, onLoading:function(request){showWaiting()}}); return false;
    }
    
    function reorder_tag_cloud(order) {
        
        if ($('re_order_freq').hasClassName('selected')) 
            $('re_order_freq').removeClassName('selected')        
       
       if ( $('re_order_alpha').hasClassName('selected'))
            $('re_order_alpha').removeClassName('selected')
        
        el = $('re_order_'+order);

        Element.addClassName(el,"selected");
            
        new Ajax.Request('/post/change_tag_cloud_order_new_channel?order='+order, {asynchronous:true, evalScripts:true, onComplete:function(request){hideWaiting()}, onLoading:function(request){showWaiting()}}); return false;
            
    }
    //--------------
    var showed_element = null;
    var showed_element_tite = null;
    
    
    
	/**
	 * 
	 * @param {Object} name
	 */
    function show_helper(name) {
    
        if (last_clicked_from_tag) {
            last_clicked_from_tag = false;
            return;
         }
        last_clicked_from_tag = false;
        
        if (name == null && showed_element!= null ) {
            new Effect.SlideUp(showed_element,{duration:.3});
            showed_element_tite.className = 'expandable-title-colapsed';
            showed_element = null;
                
        } else if ( name != null ){
            el = $(name+"-container");
            $(name+'-title').className = 'expandable-title-expanded';
            new Effect.SlideDown(el,{duration:.3});
            showed_element = el;
            showed_element_tite = $(name+'-title'); 
        }
            
       
    }
    
	var user_filter_active = null;
		
	function swap_users(what, pos_function) {
		
		//if 
		if (feed_summary.selected_users_in_list!= null && feed_summary.selected_users_in_list.length > 0 && what.id != "show_users_personalized") {
			
			yn = confirm("Existem utilizadores seleccionados. Se continuares vais perder os utilizadores que seleccionas-te.\nTens a certeza que queres continuar?");
			if ( yn ) {
				feed_summary.reset_selected_users();
				
			} else {
				return;
			}
		} 
		
		
		if (user_filter_active==null)
			user_filter_active = $('show_users_all');
		
		if (user_filter_active!= null) {
			
			Element.removeClassName(user_filter_active,'selected')
		} 
			
		
		
		Element.addClassName(what,'selected')
		user_filter_active = what;
		eval(pos_function);
		
		 
	}
    
	/**
	 * 
	 */
    function update_summary() {
        
        nameObj = $('summary_feed_name');
        nameInput = $('rss_channel_name')
        if (nameInput.value.strip() == '') {
            nameObj.innerHTML = "<b>[sem nome]</b>"
        } else {
            nameObj.innerHTML = "<b>"+nameInput.value+"</b>";
        }
    }
	/**
	 * 
	 * @param {Object} name
	 */
    function show_hide(name) {
            
        if ($(name).visible()) {
            $(name+'-title').className = 'expandable-title-colapsed';
            new Effect.Fade($(name));
        } else {
            new Effect.Appear($(name));
            $(name+'-title').className = 'expandable-title-expanded';
        }
                
    }             
    
    
    function update_tags_operators() {
        
        
        //get all element with class = summary_tag_operator inside filter_summary(id)
        
        elements = Element.getElementsByClassName($('filter_summary'),'summary_tag_operator');
        //get new val
        newVal = "&nbsp;ou ";
        tmp = $('tags_operator').value
		$('rss_channel_tags_operator').value = tmp;
		 
        if ( tmp == "2")
            newVal = "&nbsp;e ";
        
        
        for (var i=0; i<elements.length; i++){
            elements[i].innerHTML = newVal ;
        } 
        
          last_clicked_from_tag = true;
         $('rss_channel_filter_tags').focus();
          
        
        
        
          
         
    }


       
	/**
	 * 
	 * @param {Object} el
	 */ 
    function change_order(el) {
         
		 
		 //update value
		$('rss_channel_order_by').value = el.innerHTML;
		 
        parent_el = Element.up(el);
       
        parent_parent_el =  Element.up(parent_el);
        
        //get all childs with class ="selected"
        
        highlighted_el_arr = Element.getElementsByClassName(parent_parent_el,'selected');
        
        if (highlighted_el_arr == null) {
            alert("highlighted_el_arr is null");
            return;
        }
		
        
        highlighted_el = highlighted_el_arr[0];
        
        if ( highlighted_el == null ) {
            alert("Something went wrong");
            return;
        } 
                
         tmp_tex = highlighted_el.innerHTML; 
         
         highlighted_el.innerHTML = '<a href="javascript:void(0)" onclick="change_order(this)">'+tmp_tex+'</a>'
         
         Element.removeClassName(highlighted_el,'selected');
         
         //turn on the selected
         parent_el.innerHTML = el.innerHTML;
         Element.addClassName(parent_el,'selected');
         
         
         if ( parent_el.innerHTML.indexOf("Top ") > -1 ) {
		 	
            $('rss_channel_order_by').value = "Populares";
            $('rss_channel_limit_popular_by').value = parent_el.innerHTML;
			
			//alert($('rss_channel_order_by').value);
			//alert($('rss_channel_limit_popular_by').value);
         
         	
		 } else if ( parent_el.innerHTML.indexOf("Populares") > -1 ) {
            
            new Effect.Appear($('child_pop_menu'),{duration:.3});
            
            $('rss_channel_order_by').value = parent_el.innerHTML;
            
            if ($('rss_channel_limit_popular_by').value == "") {
	
                $('rss_channel_limit_popular_by').value = "Top 24 horas"
            }
                        
         } else {
            
            $('rss_channel_order_by').value = parent_el.innerHTML;

            new Effect.Fade($('child_pop_menu'),{duration:.3});
         }
         
         
         
         update_order_in_summary(el);
         

         
    }
    
	
	var users_selection = {
		
		selected_users: "all_users_098714253616263238237",
		
			
		
		use_all_users: function() {
			last_selected_user_filter = "all";
			this.update_users_text("[ todos ]");
			feed_summary.update_users("all_users_098714253616263238237");
			
		},
		use_my_network_users: function() {
			last_selected_user_filter = "network";
			this.update_users_text("[ toda a minha rede ]");
			feed_summary.update_users("all_network_098714253616263238237");
			 
		},
		
		update_users_text: function(value) {
			$('rss_channel_use_groups').value = value;
			
		}
	}
	
	
	var feed_summary = {
		selected_users_in_list:null,	
		selected_users: null,
		selected_users_label: null,
		initialized: false,
		
		get_selected_users: function() {
			return this.selected_users_in_list;
		},
		reset_selected_users: function() {
			this.selected_users_in_list = null;
			
		},
		
		add_selected_user: function(user) {
			
			if (this.selected_users_in_list == null)
				this.selected_users_in_list = new Array();

			
			this.selected_users_in_list[this.selected_users_in_list.length] = user;
				
		},
		
		remove_selected_user:function(user) {
			if (this.selected_users_in_list == null)
				this.selected_users_in_list = new Array();

			
			this.selected_users_in_list = this.selected_users_in_list.without(user); 
				
			
		},
		init: function() {
			this.initialized = true;
			this.selected_users_label = $('summary_users');
		},
		
		update_users: function(new_value) {
			
			
			if (!this.initialized)
				this.init();
				
			html_new_value = "";

			if (new_value.indexOf('all_users_098714253616263238237') >-1 ) {
				html_new_value = " de <b>todos os utilizadores</b>";	
			}	

			if (new_value.indexOf('all_network_098714253616263238237') >-1 ) {
				html_new_value = " de <b>toda a minha rede</b>";
			}	
			
			
			this.selected_users = new_value;
			this.selected_users_label.innerHTML = html_new_value; 
		}
	}
    function update_order_in_summary(el) {
    
    
        rss_channel_order_by = $('rss_channel_order_by').value;
        rss_channel_limit_popular_by = $('rss_channel_limit_popular_by').value;
            
        //alert(rss_channel_order_by);
        //alert(rss_channel_limit_popular_by);
    
        //alert(update);
        //update = el.innerHTML;
        //new_update = update;
        
        
        //if ($('rss_channel_limit_popular_by').value == "") {
        //        $('rss_channel_limit_popular_by').value = "Top 24 horas"
        //}
        
        
        new_update = rss_channel_order_by;
        
        if (rss_channel_order_by.indexOf("Populares") > -1 ) {
            
            
            
            //alert("and now");
            //get req popularity
            
            if (rss_channel_limit_popular_by.indexOf("Top 24 horas") > -1 ) {
                new_update = "mais populares das &uacute;ltimas 24 horas"
            }
            
            if (rss_channel_limit_popular_by.indexOf("Top 7 ") > -1 ) {
                new_update = "mais populares dos &uacute;ltimos 7 dias"
            }
            

            if (rss_channel_limit_popular_by.indexOf("Top 30 ") > -1 ) {
                new_update = "mais populares dos &uacute;ltimos 30 dias"
            }

            if (rss_channel_limit_popular_by.indexOf("Top 365 ") > -1 ) {
                new_update = "mais populares dos &uacute;ltimos 365 dias"
            }
        }
            
            
        $('order_summary_filter').innerHTML = "<b>"+new_update.toLowerCase()+"</b>";  
    }