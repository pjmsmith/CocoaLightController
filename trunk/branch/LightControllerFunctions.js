var loopActive = false;
var playActive = false;
var dialogActive = false;
var inputActive = false;

var numberofLights = 0;

var inputWithFocus;

var hoverConfig = {    
sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)    
interval: 300, // number = milliseconds for onMouseOver polling interval    
over: function(){if(!$(this).hasClass("playing")){$(this).children("img").fadeIn("fast");}}, // function = onMouseOver callback (REQUIRED)    
timeout: 500, // number = milliseconds delay before onMouseOut    
out: function(){$(this).children("img").hide();} // function = onMouseOut callback (REQUIRED)    
};

var hoverConfigGroup = {
sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)    
interval: 300, // number = milliseconds for onMouseOver polling interval    
over: function(){$(this).children("img").fadeIn("fast");}, // function = onMouseOver callback (REQUIRED)    
timeout: 500, // number = milliseconds delay before onMouseOut    
out: function(){$(this).children("img").hide();} // function = onMouseOut callback (REQUIRED)    
};

function deactivateLooping() {
	loopActive = false;
	$("#loopButton").attr("src","Repeat0D.tiff");
}

function deactivatePlaying() {
	playActive = false;
	$("#playButton").attr("src","Play0D.tiff");
}

$(document).ready(function(){
	//window.AppController.showMessage_("jquery works");
	$("body").keypress(function(e){
        var selectedLights = "";
        if(e.which == 117 || e.which == 105 || e.which == 106 || e.which == 111 || e.which == 107 || e.which == 108 || e.which == 109 || e.which == 44){
            selectedLights += getSelectedLights();			   
        }
        if (!dialogActive && !inputActive) {
            if (e.which == 117) { //u
					   window.AppController.setColor_selectString_selectAnimation_("yellow",selectedLights,returnSelectedAnimations());
            } 
            if (e.which == 105) { //i
					   window.AppController.setColor_selectString_selectAnimation_("green",selectedLights,returnSelectedAnimations());
            } 
            if (e.which == 111) { //o
					   window.AppController.setColor_selectString_selectAnimation_("cyan",selectedLights,returnSelectedAnimations());
            } 
            if (e.which == 106) { //j
					   window.AppController.setColor_selectString_selectAnimation_("red",selectedLights,returnSelectedAnimations());
            }
            if (e.which == 107) { //k
					   window.AppController.setColor_selectString_selectAnimation_("magenta",selectedLights,returnSelectedAnimations());
            } 
            if (e.which == 108) { //l
					   window.AppController.setColor_selectString_selectAnimation_("blue",selectedLights,returnSelectedAnimations());
            }
            if (e.which == 109) { //m
					   window.AppController.setColor_selectString_selectAnimation_("white",selectedLights,returnSelectedAnimations());
            }
            if (e.which == 44) { //,
					   window.AppController.setColor_selectString_selectAnimation_("black",selectedLights,returnSelectedAnimations());
            }
        }
					   
       if(e.which == 32 && !inputActive) {
           e.preventDefault();
           e.stopPropagation();
           
           
           var animationThatsSelected = $("#AnimationsLeft > div.selected");
           
           /*if ($("#AnimationsLeft > div.selected").length == 0){
                
           }*/
           if ($("#AnimationsLeft > div.selected").length == 1 && $("#AnimationsLeft > div.playing").length == 0){

                window.AppController.setCurrentAnimation_($("#AnimationsLeft > div.selected").attr("name"));
                window.AppController.runAnimation_("");
                animationThatsSelected.addClass("playing");
                $("#playButton").attr("src","PlayBN.tiff");
                playActive = true;

           }
           else if ( animationThatsSelected.hasClass("playing") ){

                window.AppController.runAnimation_("");
           
               if(playActive) {
                    deactivatePlaying();
                    playActive = false;
               }
               else {
                    $("#playButton").attr("src","PlayBN.tiff");
                    playActive = true;
               }
           
           }
           else if ($("#AnimationsLeft > div.selected").length == 1 && $("#AnimationsLeft > div.playing").length == 1 && (!animationThatsSelected.hasClass("playing"))) {

           $("#AnimationsLeft > div").removeClass("playing");
                window.AppController.runAnimation_("");
                window.AppController.setCurrentAnimation_($("#AnimationsLeft > div.selected").attr("name"));
                animationThatsSelected.addClass("playing");
                $("#playButton").attr("src","PlayBN.tiff");
                playActive = true;

           }
           
           else if ($("#AnimationsLeft > div.selected").length == 0 && $("#AnimationsLeft > div.playing").length == 1) {

                window.AppController.runAnimation_("");
                if(playActive){ deactivatePlaying();playActive = false	}
                else {$("#playButton").attr("src","PlayBN.tiff"); playActive = true;}
           }


       /*if($("#AnimationsLeft > div.selected").length > 0){
           var animationThatsSelected = $("#AnimationsLeft > div.selected");
           
       if(animationThatsSelected.hasClass("playing")){
           window.AppController.setCurrentAnimation_("");
            window.AppController.runAnimation_("");
           $("#AnimationsLeft > .animation").removeClass("playing");
       }
       else {
           window.AppController.setCurrentAnimation_($("#AnimationsLeft > div.playing").attr("name"));
           $("#AnimationsLeft > div.playing").removeClass("playing");
           animationThatsSelected.addClass("playing");
           $("#playButton").attr("src","PlayBN.tiff");
       }
       }

        if($("#AnimationsLeft > div.selected").length > 0){
           if(playActive){
                window.AppController.runAnimation_("");
                playActive = false;
                $("#AnimationsLeft > div.playing").removeClass("playing");
       }
           else{
                $("#playButton").attr("src","PlayBN.tiff");
                $("#AnimationsLeft > div.selected").addClass("playing");
                //window.AppController.setCurrentAnimation_($("#AnimationsLeft > div.selected").attr("name"));
                //window.AppController.runAnimation_("");
                playActive = true;
           }
           }*/
       
       
       
       }
					   
	});

	$(".colorButton").click(function(){
		var selectedLights = getSelectedLights();			   
		var color = $(this).attr("id"); 
		//window.AppController.showMessage_(color+" : "+selectedLights);
		window.AppController.setColor_selectString_selectAnimation_(color,selectedLights,returnSelectedAnimations());
	});

	$(".colorButton").mousedown(function(){
		var cssObj = {
		'opacity' : '.5'
		}
	$(this).css(cssObj);
	});

	$(".colorButton").mouseup(function(){
		var cssObj = {
			'opacity' : '1'
		}
		$(this).css(cssObj);
	});

	$(".physicalButtons").mousedown(function(){
		var cssObj = {
			'opacity' : '.5'
		}
		$(this).css(cssObj);
	});

	$(".physicalButtons").mouseup(function(){
		var cssObj = {
			'opacity' : '1'
		}
		$(this).css(cssObj);
        //var selectedLights = getSelectedLights();
		
		//window.AppController.showMessage_(displayValue("left")+"");
        //window.AppController.pulse_selectAnimation_lowValue_highValue_(selectedLights, $("#AnimationsLeft > div.selected").attr("name"), displayValue("left"), displayValue("right"));
	});

	/*$(".aniControls").mousedown(function(){
	var fileName = $(this).attr("src");
	var fileNameAlt = fileName.substr(0,fileName.length-7) +"BH.tiff";

	$(this).attr("src",fileNameAlt);

	window.AppController.runAnimation_("run");			
	});

	$(".aniControls").mouseup(function(){
	var fileName = $(this).attr("src");
	var fileNameAlt = fileName.substr(0,fileName.length-7) +"0D.tiff";

	$(this).attr("src",fileNameAlt);
	});


	$(".aniControls").mouseenter(function(){
	var fileName = $(this).attr("src");
	var fileNameAlt = fileName.substr(0,fileName.length-7) +"0N.tiff";

	$(this).attr("src",fileNameAlt);

	//window.AppController.showMessage_(fileName);

	});

	$(".aniControls").mouseleave(function(){
	var fileName = $(this).attr("src");
	var fileNameAlt = fileName.substr(0,fileName.length-7) +"0D.tiff";

	$(this).attr("src",fileNameAlt);

	//window.AppController.showMessage_(fileName);			
	//window.AppController.runAnimation_();
	}); */
	$("#playButton").mousedown(function(){
		$(this).attr("src","Play0H.tiff");
	});
	$("#playButton").click(function(){
		if(!playActive) {
			playActive = true;
			window.AppController.runAnimation_("");
			$(this).attr("src","PlayBN.tiff");
		}
		else {
			playActive = false;
			window.AppController.runAnimation_("");
			$(this).attr("src","Play0D.tiff");
		}
	});
	$("#playButton").mouseout(function(){
		if(playActive){
			$(this).attr("src","PlayBN.tiff");
		}
		else {
			$(this).attr("src","Play0D.tiff");
		}
	});
	/*
	$("#playButton").toggle(
	function() {
	window.AppController.runAnimation_("");
	$(this).attr("src","PlayBN.tiff");
	},
	function() {
	window.AppController.runAnimation_("");
	$(this).attr("src","Play0D.tiff");
	});
	$("#playButton").mousedown(function(){
	$(this).attr("src","Play0H.tiff");
	});
	$("#playButton").mouseleave(function(){
	$(this).attr("src","Play0D.tiff");
	});*/


	$("#loopButton").mousedown(function(){
		$(this).attr("src","Repeat0H.tiff");
	});
				  
	$("#loopButton").click(function(){
		if(!loopActive) {
			loopActive = true;
			window.AppController.toggleLooping_("");
			$(this).attr("src","RepeatBH.tiff");
		}
		else {
			loopActive = false;
			window.AppController.toggleLooping_("");
			$(this).attr("src","Repeat0D.tiff");
		}
	});
				  
	$("#loopButton").mouseout(function(){
		if(loopActive){
			$(this).attr("src","RepeatBH.tiff");
		}
		else {
			$(this).attr("src","Repeat0D.tiff");
		}
	});		/*$("#loopButton").toggle(
	function() {
	window.AppController.toggleLooping_("");
	$(this).attr("src","RepeatBH.tiff");
	},
	function() {
	window.AppController.toggleLooping_("");
	$(this).attr("src","Repeat0D.tiff");
	});
	$("#loopButton").mousedown(function(){
	$(this).attr("src","Repeat0H.tiff");
	});
	$("#loopButton").mouseleave(function(){
	$(this).attr("src","Repeat0D.tiff");
	});*/


	$("#blackoutButton").toggle(
		function() {
			window.AppController.blackout_("");
			$(this).attr("src","light-blackout.png");
		},
		function() {
			window.AppController.recover_("");
			$(this).attr("src","dark-blackout.png");
	});


	$("#recordButton").toggle(
		function() {
			window.AppController.toggleRecord_("");
			$(this).attr("src","Record1BN.tiff");
		},
		function() {
			window.AppController.toggleRecord_("");
			$(this).attr("src","Record0N.tiff");
	});
	
	$(".removeButton").setButtonEvents("RemoveAnimation0D.tiff","RemoveAnimationBH.tiff");

	  $("#removeAnimationButton").mouseup(function(){
		 $("div#AnimationsLeft > div.selected").hide("fast");
		 $(this).parents("div.animation").removeClass("selected");
		window.AppController.runAnimation_("");
		deactivatePlaying();
		 removeAnimation($("div#AnimationsLeft > div.selected").attr("name"));
		 });
				  
	  $("#removeGroupButton").mouseup(function() {
		  var group = $("div#groupList > div.selected");					  
		var groupName = $("div#groupList > div.selected").attr("name");					  
		  if( groupName != "all"){				  
				group.hide("fast");
				  removeGroup(group.attr("name"));
					group.removeClass("selected");
									  
				  }
		});
				  
	  $("#removeLightButton").mouseup(function() {
		  var group = $("div#lightList > div.selected");					  
									  group.each(function(){
												 //$(this).hide("fast");
												 var tempIndex = $(this).attr("index");
												 $("div[index='"+tempIndex+"']").remove();
												 removeLight(tempIndex);
												 });
		  //removeGroup(group.attr("name"));
		  //group.remove();
									  
	  });
				  
				  
	$(".addButton").setButtonEvents("NewTrack0D.tiff","NewTrackBH.tiff");			  

		$("#newAnimationButton").mouseup(function(){
			window.AppController.clearCurrentAnimationActions_("");
			$("#AnimationNameInputBox").attr("value","New Animation");
			$("#AnimationNameInputBox").show();
			inputActive = true;
			$("#AnimationNameInputBox").focus();
			$("#AnimationNameInputBox").select();
			inputWithFocus = $("#AnimationNameInputBox");
		});
				  
				  
		$("#AnimationNameInputBox").blur(function(){
			if(!$(this).is(':hidden')){	
										 $(this).getAnimationNameInput();
			}
		});
						
		  $("#newGroupButton").mouseup(function(){
									   
									   $("#tempGroupNameInput").show();
									   $("#tempGroupNameInput").focus();
	   });
				  
	  $("input").focus(function(){
					   inputActive = true;
					   });
	  $("input").blur(function(){
					   inputActive = false;
					  });
	  
      $("select").focus(function(){
                       inputActive = true;
                       });
      $("select").blur(function(){
                      inputActive = false;
                      });
                  
	  $("#tempGroupNameInput").keyup(function(e) {
									 if (e.keyCode == 13) {
									 if(!$(this).is(':hidden')){	
									 $("#tempGroupNameInput").hide();
									 $(this).getGroupNameInput();
									 }
									 }
									 });
	  
	  
	  $("#tempGroupNameInput").blur(function(){
									if(!$(this).is(':hidden')){	
									$("#tempGroupNameInput").hide();
									$(this).getGroupNameInput();
									}
									});
				  
	  $("#newLightButton").click(function() {
								 $("#dialog").dialog('open');
								 dialogActive = true;
								 });
				  

	$("#clearButton").mousedown(function(){
		window.AppController.clearCurrentAnimationActions_("");
		$(this).attr("src","ClearTrack0H.tiff");
	});
	$("#clearButton").mouseleave(function(){
		$(this).attr("src","ClearTrack0N.tiff");
	});
	$("#clearButton").mouseup(function(){
		$(this).attr("src","ClearTrack0N.tiff");				  
	});

	$("#animationSpeedInput").keydown(function(e) {
		if (e.which == 13) {

			var inputValue = $(this).attr('value');
			//var numericExpression = /^[0-9]+$/;
			if(!isNaN(inputValue)){
				//window.AppController.showMessage_();			
				window.AppController.setAnimationSpeed_(inputValue);
			}
		}
	});
	
	$("#brightnessSliderInput").keydown(function(e) {
		if (e.which == 13) {
			var inputValue = $(this).attr('value');
			//var numericExpression = /^[0-9]+$/;
			if(!isNaN(inputValue)){
				$("#slider").slider('value',inputValue);
			}
		}
	});

	$("#firstAction").mousedown(function() {
		window.AppController.firstAction_("");
		$(this).attr("src","Beginning0N.tiff");
	});
	$("#firstAction").mouseup(function() {
		$(this).attr("src","Beginning0D.tiff");
	});
	$("#firstAction").mouseleave(function() {
		$(this).attr("src","Beginning0D.tiff");
	});
	$("#prevAction").mousedown(function() {
		window.AppController.prevAction_("");
		$(this).attr("src","Rewind0N.tiff");
	});
	$("#prevAction").mouseup(function() {
		$(this).attr("src","Rewind0D.tiff");
	});
	$("#prevAction").mouseleave(function() {
		$(this).attr("src","Rewind0D.tiff");
	});
	$("#nextAction").mousedown(function() {
		window.AppController.nextAction_("");
		$(this).attr("src","FFwd0N.tiff");
	});
	$("#nextAction").mouseup(function() {
		$(this).attr("src","FFwd0D.tiff");
	});
	$("#nextAction").mouseleave(function() {
		$(this).attr("src","FFwd0D.tiff");
	});


	$("#AnimationsLeft").sortable({ cursor: 'move', opacity: 0.6, containment: 'window' });
	$(".lightGroup").droppable({drop:function() {LightDropOnGroup($(this))},hoverClass:"groupHoverDrop"});
	$(".light").draggable({ cursor: 'move', containment: 'window',connectWith:".lightGroup", helper: 'clone', revert:true, revertDuration:'1',drag: $(this).checkIfSingleDrag });
	$(".filterDropBoxContent").droppable({drop:function(){$(".filterDropBoxContent").removeClass("selected");$(this).addClass("selected");},hoverClass:"selected"});
				  
				  
	$(".physicalButtons").droppable({
		drop: function(event,ui) {
			
			var tempName = $(ui.draggable).attr("name");
			var droppableId = $(this).attr("id");
																		
			window.AppController.setButtonAction_action_(droppableId,tempName+"");
			//window.AppController.showMessage_(""+droppableId +" : "+ tempName);
									
		},
		hoverClass: 'droppableHover',
		tolerance: 'pointer'
	});


	$(function() {
        $("#slider").slider({ min: 0, max:255, step: 15,value:255});
        $("#sliderleft").slider({ min: 0, max:255, step: 15,value:255,orientation: 'vertical'});
        $("#slidercenter").slider({ min: 0, max:255, step: 15,value:255,orientation: 'vertical'});
        $("#sliderright").slider({ min: 0, max:255, step: 15,value:255,orientation: 'vertical'});
	});	

	$("#slider").bind('slide', function(event, ui) {
		//var value = $("#slider").slider('option', 'value');
		var value = ui.value;			  
		if (value > 255) {
            value = 255;
		}
		$("#brightnessSliderInput").attr("value",value);
		window.AppController.setBrightness_selectString_selectAnimation_(value,getSelectedLights(),$("#AnimationsLeft > div.selected").attr("name"));

	});
	
				  
	$("#dialog").dialog({ resizable: false, buttons: { 
        "Save": function() { 

            addLight();
            /*$(this).dialog("close");
            dialogActive = false;
            var lightName = $("input[name='lightName']").attr("value");
            //var channelNumber = $("select[name='lightChannels']").attr("value");
            var channelNumber = 7;
            var channelNames = $("input[name='ch1']").attr("value");
            for (i=2;i<=channelNumber;i++) {
                var selector = "ch"+i;
                channelNames = channelNames + ","+$("input[name="+selector+"]").attr("value");
            }
            //window.AppController.showMessage_(lightName+","+channelNumber+","+channelNames);
            //window.AppController.addLight_(lightName,channelNumber,channelNames);
            var lightName =window.AppController.addLight_numChans_newLabels_(lightName, channelNumber, channelNames);
            $("#lightList").append("<div class='light'>"+lightName+"</div>");
            $("#group0").append("<li>"+lightName+"</li>");
            //window.AppController.showMessage_(lightName+","+channelNumber+","+channelNames);*/

            },
        "Cancel":function() {
            $(this).dialog("close");
            $("select").blur();
            dialogActive = false;

            }
        } 
    });



    $("#dialog").dialog("close");
				  
    $("body").keyup(function(e) {
        if (e.keyCode == 13) {
            if(dialogActive){	
                addLight();
            }
			if(!inputWithFocus.is(":hidden")){
					inputWithFocus.getAnimationNameInput();	
			}
        }
    });
				
				  
    $(".animation").live("click",function() {
						 $(this).toggleClass("selected");
						 var animationHadClass = $(this).hasClass("selected");
						 $(".animation").removeClass("selected");
						 if(animationHadClass)
						{
							$(this).addClass("selected");
						 }
    });
				  
    $(".animation > .animationControlRemove").live("click",function() {
        $(this).parents("div.animation").hide("fast");
		$(this).parents("div.animation").removeClass("selected");
		//window.AppController.removeAnimation_($(this).attr("name"));
		 removeAnimation($(this).parents("div.animation").attr('name'));
    });
				  
	  $("#AnimationsLeft > div.animation").live("dblclick",function() {
		if(!$(this).hasClass("playing")) {
			$(".animation").removeClass("playing");
			$(this).removeClass("selected");
			$(this).addClass("playing");
			window.AppController.setCurrentAnimation_($(this).attr("name"));
			$(this).children("img").hide();
		}
		else {
			$(this).removeClass("playing");
			window.AppController.setCurrentAnimation_("");
		}
	});
				  
	  
    $(".filterDropBoxContent").live("click",function() {
        //$(this).toggleClass("selected");
        if ($(this).hasClass("selected")) {
            $(this).removeClass("selected");
        }
        else {
            $(".filterDropBoxContent").removeClass("selected");
            $("#groupList > div").removeClass("selected");
            $(".light").removeClass("selected");


            $(this).addClass("selected");
        }

    });
                  
    $("#center").click(function(e){
        var pos = $(this).offset();  
        var height = $(this).height();
        var width = $(this).width();

        var x = e.pageX - pos.left;
        var y = e.pageY - pos.top;

        if (x/width <= 0.25){
            //window.AppController.showMessage_(x/width+","+y/height);
            changeDisplay("left",1-(y/height));
        }
        if (x/width > 0.25 && x/width < 0.75){
            changeDisplay("center",1-(y/height));
        }
        if (x/width >= 0.75){
            changeDisplay("right",1-(y/height));
        }
    });	
				  
				  
    $('.animation').live('mouseover', function() {  
        if (!$(this).data('init')) {  
            $(this).data('init', true);
            $(this).hoverIntent(hoverConfig);			     
            $(this).trigger('mouseover');  
        }  
    });
				  
	  $('.lightGroup > .light').live('mouseover',function(){
								  if (!$(this).data('init')) {  
								  $(this).data('init', true);
								  $(this).hoverIntent(hoverConfigGroup);			     
								  $(this).trigger('mouseover');  
								  }
		});

    $("#groupList > div").live("click",function() {
                              
        if($(this).hasClass("selected")){
            $(this).removeClass("selected")
        }
        else {
            $(".filterDropBoxContent").removeClass("selected");
            $(".light").removeClass("selected");
            $("#groupList > div").removeClass("selected");
            $(this).addClass("selected");
        }

    });
				  
    $("#groupList > div").live("dblclick",function() {
        if(!$(this).children("div").is(":hidden")) {
            $(this).children("div").slideUp();
			$(this).attr("collapsed","true");				   
            //$(this).removeClass("selected");
        }
        else{
            if($(this).attr("name") != "all") {
                $("#groupList > div > div.light").slideUp();
				$("#groupList > div").attr("collapsed","true");
                $(this).children("div").slideDown();
				$(this).attr("collapsed","false");				   
            }
            //$(this).addClass("selected");
        }
    });
				  
	
	  $(".lightGroup > .light > img").live("click",function() {
													 $(this).parents("div.light").hide("fast");
													 $(this).parents("div.light").removeClass("selected");
													 //window.AppController.removeAnimation_($(this).attr("name"));
													 removeLight($(this).parents("div.light").attr('index'));
													$(this).parents("div.light").remove();
													 });


	
	$("body").keypress(function(e){
					   var tempKeyNumberConvert = e.which - 48;
					   if(!inputActive) {
                       if(e.metaKey){
						   //window.AppController.showMessage_("command Key");
						   if(e.which > 47 && e.which < 58 ){ //numbers 1-9 and 0 on keyboard
								   e.preventDefault();
								   e.stopPropagation();

								AssignToFilterDropBox(tempKeyNumberConvert);
							   
						   }
					   }
					   else{
					   //e.preventDefault();
					   e.stopPropagation();
							if(e.which > 47 && e.which < 58 ){ //numbers 1-9 and 0 on keyboard
								var tempGroupName = $("#filterList > li[key='"+e.which+"']").attr("name");
							

					   if (!$(".filterDropBoxContent[name='filter"+tempKeyNumberConvert+"']").hasClass("selected")) {
					   $(".filterDropBoxContent").removeClass("selected");
					   $("#groupList > div").removeClass("selected");

					   $("#lightList > div").removeClass("selected");
					   //$("#filterList > li").removeClass("selected");
								$(".filterDropBoxContent[name='filter"+tempKeyNumberConvert+"']").addClass("selected");
					   }
					   else {
						$(".filterDropBoxContent[name='filter"+tempKeyNumberConvert+"']").removeClass("selected");
					   }
					   
							}
					   if (e.which == 96){
						   $("#groupList > div").removeClass("selected");
						   $("#lightList > div").removeClass("selected");
						   $("#filterList > li").removeClass("selected");
                           $(".filterDropBoxContent").removeClass("selected");

						   $("#groupList > .lightGroup[name='all']").addClass("selected");
						   }
					   }
                       }
	});

    $(".light").live("click",function(e) {
        $("#filterList > li").removeClass("selected");
        $("#groupList > div").removeClass("selected");
		//window.AppController.showMessage_(""+$(this).attr('index'));

        if(e.metaKey){
            $(this).toggleClass("selected");
        }
		else if(e.shiftKey){
					 if($("#lightList > .selected").length == 0 || ($(this).hasClass("selected") && $("#lightList > .selected").length == 1)){
						$(this).toggleClass("selected");
					 }
					 if(!$(this).hasClass("selected") && $("#lightList > .selected").length > 0){
					 $(this).addClass("selected");
						var minSelectedIndex = 512;
						var maxSelectedIndex = -1;
					 $("#lightList > .light").each(function(){
												  if($(this).hasClass("selected")) {
													 var tempIndex = $(this).attr("index");
													 if(tempIndex < minSelectedIndex ) { minSelectedIndex = tempIndex; }
													 if(tempIndex > maxSelectedIndex ) { maxSelectedIndex = tempIndex; }
												  }
						});
					 $("#lightList > .light").each(function(){
						var tempIndex = $(this).attr("index");

												   //window.AppController.showMessage_("lightIndex: "+tempIndex+" minSelected:"+minSelected+" maxSelectedIndex:"+maxSelectedIndex+" = "+$(this).attr("name"));
												   if(tempIndex >= minSelectedIndex && tempIndex <= maxSelectedIndex && !$(this).hasClass("selected")) {
													$(this).addClass("selected");
												   //window.AppController.showMessage_(""+tempIndex);
												   }
						});
					 }
		}
					 
		/*if (e.shiftKey{
			$(".light").each(function(index){
					//$this).		 
			});
		}*/
					 
        else {
            $(".light").removeClass("selected");
            $(this).toggleClass("selected");
        }
    });

});

function addLight() {
	$("#dialog").dialog("close");
    $("select").blur();
	dialogActive = false;
	var lightName = $("input[name='lightName']").attr("value");
	//var channelNumber = $("select[name='lightChannels']").attr("value");
	var channelNumber = 7;
	var channelNames = $("input[name='ch1']").attr("value");
	for (i=2;i<=channelNumber;i++) {
		var selector = "ch"+i;
		channelNames = channelNames + ","+$("input[name="+selector+"]").attr("value");
	}
	
	//var numberofLights = $(".light").length;
	
	//window.AppController.showMessage_(lightName+","+channelNumber+","+channelNames);
	//window.AppController.addLight_(lightName,channelNumber,channelNames);
	for(i = 0; i<$("select[name='numLights']").attr("value");i++)
	{
		var lightName2 = window.AppController.addLight_numChans_newLabels_(lightName, channelNumber, channelNames);
		$("#lightList").append("<div class='light' index='"+numberofLights+"' name='"+lightName2+"'>"+lightName2+"</div>");
		//$("#group0").append("<div id='"+numberofLights+"' name='"+lightName+"'>"+lightName+"</div>");
		//window.AppController.showMessage_(""+numberofLights);
		numberofLights++;
	}
	
	$(".light").draggable( 'destroy' );
	$(".light").draggable({ cursor: 'move', containment: 'window',connectWith:"#groupList", helper: 'clone', revert:true, revertDuration:'1',drag: $(this).checkIfSingleDrag  });
	
	}

function changeDisplay(display,value) {
	// display parameter can be: left, right, or center
	// value must lie between 0 and 1 represented in percent
	var animateSpeed = 100;
	
	display = display.toLowerCase();
	
	switch(display) {
        case "left":
            value = $("#centerLeftDisplay").height() * ( 1 - value);
            $("#centerLeftDisplay > .modifier").animate({ height: value },animateSpeed);
        break;
        case "center":
            var heightValue = $("#centerCenterDisplay").height() * ( 1 - value);
            $("#centerCenterDisplay > .modifier").animate({ height: heightValue },animateSpeed);
            var brightnessValue = 255 * value;
            //window.AppController.showMessage_(""+brightnessValue);
            window.AppController.setBrightness_selectString_selectAnimation_(brightnessValue,getSelectedLights(),$("#AnimationsLeft > div.selected").attr("name"));
        break;
        case "right":
            value = $("#centerRightDisplay").height() * ( 1 - value);
            $("#centerRightDisplay > .modifier").animate({ height: value },animateSpeed);
        break;
	}
	
}

function displayValue(display){
	display = display.toLowerCase();
	var value;

	switch(display) {
			case "left":
				value = ( $("#centerLeftDisplay > .modifier").height() / $("#centerLeftDisplay").height());
			break;
			case "center":
				value = ( $("#centerCenterDisplay > .modifier").height() / $("#centerCenterDisplay").height());
			break;
			case "right":
				value = ( $("#centerRightDisplay > .modifier").height() / $("#centerRightDisplay").height());
			break;
	}
	value = 255 * (1-value);
	return value;
}

function switchToAnimation(animationName) {
	window.AppController.setCurrentAnimation_(animationName);
	window.AppController.runAnimation_("");
	$("div.animation").removeClass("playing");
	$("div.animation[name='"+animationName+"']").addClass("playing");
}

function LightDropOnGroup(el) {
	//var numLights = 0;
	
	$(".ui-draggable-dragging").removeClass("selected");
	//window.AppController.showMessage_(""+numLights);
	//window.AppController.showMessage_(""+el.text());
	
	var numLights = $("#lightList > .selected").length;
	
	/*if (numLights == 0) {
		$(".ui-draggable-dragging").addClass("selected");
	}*/
	
	var lightsToAdd = "";
	var nameOfGroupBeingDroppedOn = el.attr("name");
	//var numLights = ".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']";
	//window.AppController.showMessage_(""+numLights);
	
	if(numLights == 0) {
		var lightName = $(".ui-draggable-dragging").attr("name");
		var lightIndex = $(".ui-draggable-dragging").attr("index");
		if(el.children("div[name='"+lightName+"']").length == 0){
			//$("#lightList > .light[name='"+lightName+"']").clone(true).appendTo(".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']");
			$(".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']").append("<div name='"+lightName+"' index='"+lightIndex+"' class='light'>"+lightName+"<img class='removeGroupImage' src='removeAnimation.png'/></div>");
			lightsToAdd = lightIndex;
		}
	}
	else {	
		$("#lightList > .selected").each(function(){
										var lightName = $(this).attr("name");
										 var lightIndex = $(this).attr("index");
										 $(this).removeClass("selected");

										 if(el.children("div[name='"+lightName+"']").length == 0){
											//$(this).clone(true).appendTo(".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']");
										 $(".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']").append("<div name='"+lightName+"' index='"+lightIndex+"' class='light'>"+lightName+"<img class='removeGroupImage' src='removeAnimation.png'/></div>");
											lightsToAdd += $(this).attr("index") +",";
										 }
										 //window.AppController.showMessage_("dropped on: "+nameOfGroupBeingDroppedOn);
										 //window.AppController.showMessage_("dropped on: "+$(this).attr("name"));
										 $(this).addClass("selected");
										 
		});
		lightsToAdd = lightsToAdd.substring(0, lightsToAdd.length-1); //remove last comma
	}
	
	if(el.attr("collapsed") == "true"){
		el.children("div.light").hide();
	}
	else {
		el.children("div.light").show();
	}
	//var numLights = $(".lightGroup > .light").length;
	//window.AppController.showMessage_(""+numLights);
	
	/*$("#groupList > li > ul > li").draggable('destroy');
	$("#groupList > li > ul > li").draggable({ cursor: 'move', containment: 'window',connectWith:"#groupList", revert:true,revertDuration:'100' });*/
	
	if(lightsToAdd.length == 0) {
			lightsToAdd = "-1";
	}
	
	//window.AppController.showMessage_(""+$("#AnimationsLeft > div.selected").attr("name"));
	window.AppController.appendToGroup_selected_selectAnimation_(nameOfGroupBeingDroppedOn,lightsToAdd,$("#AnimationsLeft > div.selected").attr("name"));
	
	//$("#AnimationsLeft").append("<div class='animation'>Animation "+numofAnimations+"<img class='animationControlRemove' src='removeAnimation.png'/></div>");
	
}

function getSelectedLights() {

	var selected = "g";
	$(".filterDropBox > div.selected>span").each(function(){
		selected += ","+$(this).text();
    });
	$("#groupList > .selected").each(function() {
        selected += ","+$(this).attr("name");
    });
	
	if ($("#lightList > div.selected").length > 0) {
		selected = "l";

		$("#lightList > div.selected").each(function() {
            //if($(this).hasClass("selected")){
                selected += "," +$(this).attr("index");;
            //}
        });
	}
	//window.AppController.showMessage_(selected);
	if (selected.length > 1){
		return selected;
	}
	else {
		//window.AppController.showMessage_("g,All");
		return "g,all";
	}
}

function getSelectedLightsForGroup() {

    selected = "";

    $("#lightList > div.selected").each(function() {
        //if($(this).hasClass("selected")){
            selected += $(this).attr('index') + ",";
        //}
    });
    selected = selected.substring(0, selected.length-1); //remove last comma
    //window.AppController.showMessage_(selected);
	
	if (selected.length > 0){
		return selected;
	}
	else {
		//window.AppController.showMessage_("-1");
		return "-1";
	}
	
}

jQuery.fn.getGroupNameInput = function() {
    var tempGroupName = $(this).attr("value");
    var passedGroupName = "";
    var lightsInGroup = "";
    
    passedGroupName = window.AppController.addGroup_selected_(tempGroupName,getSelectedLightsForGroup());
    
    $("#lightList > .selected").each(function(){
                                     lightsInGroup += "<div class='light' index='"+$(this).attr('index')+"' name='"+$(this).text()+"'>"+$(this).text()+"<img class='removeGroupImage' src='removeAnimation.png'/></div>";
                                     });
	
    $("#groupList").append("<div class='lightGroup' collapsed='true' name='"+passedGroupName+"'>"+passedGroupName+lightsInGroup+"</div>");
	
	$(".lightGroup[name='"+passedGroupName+"']").children("div.light").hide();
	
	$(".lightGroup").droppable('destroy');
	$(".lightGroup").droppable({drop:function() {LightDropOnGroup($(this))},hoverClass:"groupHoverDrop"});
	
	/*$("#groupList > li > ul > li").draggable('destroy');
	$("#groupList > li > ul > li").draggable({ cursor: 'move', containment: 'window',connectWith:"#groupList", revert:true,revertDuration:'100' });*/

}


jQuery.fn.getAnimationNameInput = function() {
    var tempAnimationName = $(this).attr("value");
    var passedAnimationName = "";
    
    passedAnimationName = window.AppController.addAnimation_(tempAnimationName);
	
    $("#AnimationsLeft").append("<div class='animation' name='"+passedAnimationName+"'>"+passedAnimationName+"<img class='animationControlRemove' src='removeAnimation.png'/></div>");	
	$("#AnimationsLeft").scrollTop($("#AnimationsLeft").attr("scrollHeight"));
	
	$("#AnimationNameInputBox").hide();
	inputActive = false;
}

function addAnimationWithName(animationName)
{
    passedAnimationName = window.AppController.addAnimation_(animationName);
	
    $("#AnimationsLeft").append("<div class='animation' name='"+passedAnimationName+"'>"+passedAnimationName+"<img class='animationControlRemove' src='removeAnimation.png'/></div>");	
	$("#AnimationsLeft").scrollTop($("#AnimationsLeft").attr("scrollHeight"));    
}

jQuery.fn.checkIfSingleDrag = function() {
	if(!$(this).hasClass("selected")){
		var tempName = $(this).attr("name");
		$("#lightList > .light").removeClass("selected");
		$(".lightList > .light[name='"+tempName+"']").addClass("selected");
	}
}




function returnSelectedAnimations(){
	return $("#AnimationsLeft > div.selected").attr("name")+"";
}

jQuery.fn.setButtonEvents = function(img, mousedownimg, hoverimg) {
	
	//First 2 arguments are required. Include the third if you wish to have a hover img to display as well.

	$(this).mousedown(function(){
				$(this).attr("src",mousedownimg);
  });

	$(this).mouseup(function(){
				$(this).attr("src",img);
	});
	
	if (arguments.length == 3) {
		
		$(this).mouseover(function(){
				$(this).attr("src",hoverimg);
	   });
		
		$(this).mouseleave(function(){
				$(this).attr("src",img);
		});
		
	}
	
}

function AssignToFilterDropBox(KeyNumber){
	
	if($("#groupList > div.selected").length == 1){ // command + number assigns selected group to filter
		var tempGroupName = $("#groupList > div.selected").attr("name");
		$(".filterDropBoxContent[name='filter"+KeyNumber+"']").children("span").text(""+tempGroupName);
	}
}

function setAnimationSpeedInputText(speed) {
    $("#animationSpeedInput").attr('value', speed);
}

/*
 ---------------------System Private Functions----------------------------

 These functions are static: they don't have javascript/jquery selectors or perform dom manipulation. They are independant of the html layout.
 
*/

function removeAnimation(name) {
	// removes an animation from the cocoa code. Takes a name as parameter since names are unique to an animation
	window.AppController.removeAnimation_(name+"");
	//window.AppController.showMessage_(name+"");
}

function removeGroup(name) {
	// removes a group from the cocoa code. Takes a name as parameter since names are unique to a group
	window.AppController.removeGroup_(name+"");
	//window.AppController.showMessage_(name+"");
}

function removeLight(index) {
	// removes a light from the cocoa code. Takes the index of the light because the lights are always in the same order
	window.AppController.removeLight_(index);
	//window.AppController.showMessage_(name+"");
}