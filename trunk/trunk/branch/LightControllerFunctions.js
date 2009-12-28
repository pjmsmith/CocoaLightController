var loopActive = false;
var playActive = false;
var dialogActive = false;
var inputActive = false;
var inputWithFocus;

var hoverConfig = {    
sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)    
interval: 300, // number = milliseconds for onMouseOver polling interval    
over: function(){if(!$(this).hasClass("playing")){$(this).children("img").fadeIn("fast");}}, // function = onMouseOver callback (REQUIRED)    
timeout: 500, // number = milliseconds delay before onMouseOut    
out: function(){$(this).children("img").fadeOut("fast");} // function = onMouseOut callback (REQUIRED)    
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
					   window.AppController.setColor_selectString_selectAnimation_("yellow",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            } 
            if (e.which == 105) { //i
					   window.AppController.setColor_selectString_selectAnimation_("green",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            } 
            if (e.which == 111) { //o
					   window.AppController.setColor_selectString_selectAnimation_("cyan",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            } 
            if (e.which == 106) { //j
					   window.AppController.setColor_selectString_selectAnimation_("red",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            }
            if (e.which == 107) { //k
					   window.AppController.setColor_selectString_selectAnimation_("magenta",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            } 
            if (e.which == 108) { //l
					   window.AppController.setColor_selectString_selectAnimation_("blue",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            }
            if (e.which == 109) { //m
					   window.AppController.setColor_selectString_selectAnimation_("white",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            }
            if (e.which == 44) { //,
					   window.AppController.setColor_selectString_selectAnimation_("black",selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
            }
        }
	});

	$(".colorButton").click(function(){
		var selectedLights = getSelectedLights();			   
		var color = $(this).attr("id"); 
		//window.AppController.showMessage_(color+" : "+selectedLights);
		window.AppController.setColor_selectString_selectAnimation_(color,selectedLights,$("#AnimationsLeft > div.selected").attr("name"));
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

	$("#newButton").mousedown(function(){
			window.AppController.clearCurrentAnimationActions_("");
			$(this).attr("src","NewTrackBH.tiff");
		});
		$("#newButton").mouseleave(function(){
			$(this).attr("src","NewTrack0D.tiff");
		});
		$("#newButton").mouseup(function(){
			//var numofAnimations = $(".animation").length;
			//numofAnimations = numofAnimations + 1;
			$(this).attr("src","NewTrack0D.tiff");
			//--------window.AppController.addAnimation_name_("");
			$("#AnimationNameInputBox").attr("value","New Animation");
			$("#AnimationNameInputBox").show();
			$("#AnimationNameInputBox").focus();
			$("#AnimationNameInputBox").select();
			inputWithFocus = $("#AnimationNameInputBox");
			
			//$("#AnimationsLeft").append("<div class='animation'>Animation "+numofAnimations+"<img class='animationControlRemove' src='removeAnimation.png'/></div>");
			//$(".animation").hoverIntent( hoverConfig );
			
	});
				  
		$("#AnimationNameInputBox").blur(function(){
			if(!$(this).is(':hidden')){	
										 $(this).getAnimationNameInput();
			}
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

	$("#removeButton").mousedown(function(){
		//window.AppController.clearCurrentAnimationActions_("");
			$(this).attr("src","RemoveAnimationBH.tiff");
		});
		$("#removeButton").mouseleave(function(){
			$(this).attr("src","RemoveAnimation0D.tiff");
		});
		$("#removeButton").mouseup(function(){
			$(this).attr("src","RemoveAnimation0D.tiff");
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

	$(".physicalButtons").droppable({
		drop: function() { 
			window.AppController.showMessage_("physical buttons");
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

            dialogActive = false;

            }
        } 
    });

    $("#addLightButton").click(function() {
         $("#dialog").dialog('open');
         dialogActive = true;
    });

    $("#dialog").dialog("close");
				  
    $("body").keyup(function(e) {
        if (e.keyCode == 13) {
            if(dialogActive && !inputActive){	
                addLight();
            }
			if(!inputWithFocus.is(":hidden")){
					inputWithFocus.getAnimationNameInput();	
			}
        }
    });
				  
				  
    $(".animation").live("click",function() {
		 if(!$(this).hasClass("playing")){
			$(".animation").removeClass("selected");		
			$(this).toggleClass("selected");
		 }
    });
				  
    $(".animation > .animationControlRemove").live("click",function() {
        $(this).parents(".animation").fadeOut("slow");
		window.AppController.removeAnimation_($(this).attr("name"));
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
				  
	  
    $("#filterList > *").live("click",function() {
        //$(this).toggleClass("selected");
        if ($(this).hasClass("selected")) {
            $(this).removeClass("selected");
        }
        else {
            $("#filterList > *").removeClass("selected");
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

    $("#groupList > div").live("click",function() {
                              
        if($(this).hasClass("selected")){
            $(this).removeClass("selected")
        }
        else {
            $("#filterList > li").removeClass("selected");
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
				  
	
  				  
    $("#addGroupButton").click(function(){

       // $("#groupList > li").removeClass("selected");
        //$(".lightGroup").slideUp(function(){
            $("#tempGroupNameInput").show();
            $("#tempGroupNameInput").focus();
        //});
    });
    
				  $("input").focus(function(){
								   inputActive = true;
								   })
				  $("input").focus(function(){
								   inputActive = false;
								   })
				  
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
	
	$("body").keypress(function(e){
					   if(e.metaKey){
						   //window.AppController.showMessage_("command Key");
						   if(e.which > 47 && e.which < 58 ){ //numbers 1-9 and 0 on keyboard
								   e.preventDefault();
								   e.stopPropagation();
							   if($("#groupList > div.selected").length == 1){ // command + number assigns selected group to filter
									var tempGroupName = $("#groupList > div.selected").attr("name");
								   var tempKeyNumberConvert = e.which - 48;
								   if($("#filterList > li[name='"+tempGroupName+"']").length == 0){
										$("#filterList").append("<li key='"+e.which+"'name='"+tempGroupName+"'>("+tempKeyNumberConvert+") "+tempGroupName+"</li>");
								   }
								   else{
										$("#filterList > li[name='"+tempGroupName+"']").html("("+tempKeyNumberConvert+") "+tempGroupName)
										$("#filterList > li[name='"+tempGroupName+"']").attr("key",e.which);
								   }
							   }
						   }
					   }
					   else{
					   //e.preventDefault();
					   e.stopPropagation();
							if(e.which > 47 && e.which < 58 ){ //numbers 1-9 and 0 on keyboard
								var tempGroupName = $("#filterList > li[key='"+e.which+"']").attr("name");
								$("#groupList > div").removeClass("selected");
								$("#lightList > div").removeClass("selected");
								$("#filterList > li").removeClass("selected");

					   
								$("#filterList > li[name='"+tempGroupName+"']").addClass("selected");
							}
					   if (e.which == 96){
						   $("#groupList > div").removeClass("selected");
						   $("#lightList > div").removeClass("selected");
						   $("#filterList > li").removeClass("selected");
						   
						   
						   $("#filterList > li[name='all']").addClass("selected");
						   }
					   }
	});

    $(".light").live("click",function(e) {
        $("#filterList > li").removeClass("selected");
        $("#groupList > div").removeClass("selected");

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
												   //window.AppController.showMessage_("finding min/max"+$(this).attr("name"));
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
	dialogActive = false;
	var lightName = $("input[name='lightName']").attr("value");
	//var channelNumber = $("select[name='lightChannels']").attr("value");
	var channelNumber = 7;
	var channelNames = $("input[name='ch1']").attr("value");
	for (i=2;i<=channelNumber;i++) {
		var selector = "ch"+i;
		channelNames = channelNames + ","+$("input[name="+selector+"]").attr("value");
	}
	
	var numberofLights = $(".light").length;
	
	//window.AppController.showMessage_(lightName+","+channelNumber+","+channelNames);
	//window.AppController.addLight_(lightName,channelNumber,channelNames);
	var lightName =window.AppController.addLight_numChans_newLabels_(lightName, channelNumber, channelNames);
	$("#lightList").append("<div class='light' index='"+numberofLights+"' name='"+lightName+"'>"+lightName+"</div>");
	//$("#group0").append("<div id='"+numberofLights+"' name='"+lightName+"'>"+lightName+"</div>");
	//window.AppController.showMessage_(lightName+","+numberofLights+","+channelNames);
	
	
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
			$(".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']").append("<div name='"+lightName+"' index='"+lightIndex+"' class='light'>"+lightName+"</div>");
			lightsToAdd = lightIndex;
		}
	}
	else {	
		$("#lightList > .selected").each(function(){
										var lightName = $(this).attr("name");
										 $(this).removeClass("selected");

										 if(el.children("div[name='"+lightName+"']").length == 0){
											$(this).clone(true).appendTo(".lightGroup[name='"+nameOfGroupBeingDroppedOn+"']");
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
	$("#filterList > .selected").each(function(){
		selected += ","+$(this).attr("name");
    });
	$("#groupList > .selected").each(function() {
        selected += ","+$(this).attr("name");
    });
	
	if ($("#lightList > .selected").length > 0) {
		selected = "l";

		$(".light").each(function(index) {
            if($(this).hasClass("selected")){
                selected += "," +index;
            }
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

    $("#lightList > .light").each(function(index) {
        if($(this).hasClass("selected")){
            selected += index + ",";
        }
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
                                     lightsInGroup += "<div class='light' name='"+$(this).text()+"'>"+$(this).text()+"</div>";
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
}

jQuery.fn.checkIfSingleDrag = function() {
	if(!$(this).hasClass("selected")){
		var tempName = $(this).attr("name");
		$("#lightList > .light").removeClass("selected");
		$(".lightList > .light[name='"+tempName+"']").addClass("selected");
	}
}