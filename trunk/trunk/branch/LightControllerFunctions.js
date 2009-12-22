var loopActive = false;
var playActive = false;
var dialogActive = false;

var numofAnimations = 5;

var hoverConfig = {    
sensitivity: 3, // number = sensitivity threshold (must be 1 or higher)    
interval: 300, // number = milliseconds for onMouseOver polling interval    
over: function(){$(this).children("img").fadeIn("fast");}, // function = onMouseOver callback (REQUIRED)    
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
            selectedLights += getSelectedLights(false);			   
        }
        if (!dialogActive) {
            if (e.which == 117) { //u
               window.AppController.setColor_selectString_("yellow",selectedLights);			
            } 
            if (e.which == 105) { //i
               window.AppController.setColor_selectString_("green",selectedLights);			
            } 
            if (e.which == 111) { //o
                window.AppController.setColor_selectString_("cyan",selectedLights);			
            } 
            if (e.which == 106) { //j
                window.AppController.setColor_selectString_("red",selectedLights);			
            }
            if (e.which == 107) { //k
                window.AppController.setColor_selectString_("magenta",selectedLights);			
            } 
            if (e.which == 108) { //l
                window.AppController.setColor_selectString_("blue",selectedLights);			
            }
            if (e.which == 109) { //m
                window.AppController.setColor_selectString_("white",selectedLights);
            }
            if (e.which == 44) { //,
                window.AppController.setColor_selectString_("black",selectedLights);
            }
        }
	});

	$(".colorButton").click(function(){
		var selectedLights = getSelectedLights();			   
		var color = $(this).attr("id"); 
		//window.AppController.showMessage_(color);
		window.AppController.setColor_selectString_(color, selectedLights);
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
			$(this).attr("src","NewTrack0D.tiff");
			numofAnimations = numofAnimations + 1;
			$("#AnimationsLeft").append("<div class='animation'>Animation "+numofAnimations+"<img class='animationControlRemove' src='removeAnimation.png'/></div>");
			//$(".animation").hoverIntent( hoverConfig );

			
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
	$("#groupList > li").droppable({drop:LightDropOnGroup,hoverClass:"groupHoverDrop"});
	$(".light").draggable({ cursor: 'move', containment: 'window',connectWith:"#groupList", helper: 'clone', revert:true, revertDuration:'1' });

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
		window.AppController.setBrightness_selectString_(value,getSelectedLights());

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
				  
    $("#dialog").keyup(function(e) {
        if (e.keyCode == 13) {
            if(dialogActive){	
                addLight();
            }
        }
    });
				  
				  
    $(".animation").live("click",function(){
        $(".animation").removeClass("selected");		
        $(this).toggleClass("selected");
    });
				  
    $(".animation > .animationControlRemove").live("click",function(){
        $(this).parents(".animation").fadeOut("slow");
    });
	  
    $("#filterList > *").live("click",function(){
        //$(this).toggleClass("selected");
        if ($(this).hasClass("selected")){
            $(this).removeClass("selected");
        }
        else {
            $("#filterList > *").removeClass("selected");
            $("#groupList > li").removeClass("selected");
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

    $("#groupList > li").live("click",function() {
                              
        if($(this).hasClass("selected")){
            $(this).removeClass("selected")
        }
        else {
            $("#filterList > li").removeClass("selected");
            $(".light").removeClass("selected");
            $("#groupList > li").removeClass("selected");
            $(this).addClass("selected");
        }

    });
				  
    $("#groupList > li").live("dblclick",function() {
        if(!$(this).children("ul").is(":hidden")) {
            $(this).children("ul").slideUp();
            //$(this).removeClass("selected");
        }
        else{
            if($(this).attr("name") != "allLightsGroup") {
                $(".lightsInGroup").slideUp();
                $(this).children("ul").slideDown();
            }
            //$(this).addClass("selected");
        }
    });
				  
				  
				  
    $("#addGroupButton").click(function(){

        $("#groupList > li").removeClass("selected");
        $(".lightsInGroup").slideUp(function(){
            $("#tempGroupNameInput").show();
            $("#tempGroupNameInput").focus();
        });
    });
				  
    $("#tempGroupNameInput").blur(function(){
        $("#tempGroupNameInput").hide();
        var tempGroupName = $(this).attr("value");
        var passedGroupName ="";
        var lightsInGroup = "";

        passedGroupName = window.AppController.addGroup_selected_(tempGroupName,getSelectedLightsForGroup());

        $("#lightList > .selected").each(function(){
        lightsInGroup += "<li>"+$(this).text()+"</li>";
                                         });
        $("#groupList").append("<li name='"+passedGroupName+"'>"+passedGroupName+"<ul class='lightsInGroup'>"+lightsInGroup+"</ul></li>");

    });
				  

    $(".light").live("click",function(e) {
        $("#filterList > li").removeClass("selected");
        $("#groupList > li").removeClass("selected");

        if(e.metaKey){
            $(this).toggleClass("selected");
        }
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
	//window.AppController.showMessage_(lightName+","+channelNumber+","+channelNames);
	//window.AppController.addLight_(lightName,channelNumber,channelNames);
	var lightName =window.AppController.addLight_numChans_newLabels_(lightName, channelNumber, channelNames);
	$("#lightList").append("<div class='light'>"+lightName+"</div>");
	$("#group0").append("<li>"+lightName+"</li>");
	//window.AppController.showMessage_(lightName+","+channelNumber+","+channelNames);
	
	
	$(".light").draggable( 'destroy' );
	$(".light").draggable({ cursor: 'move', containment: 'window',connectWith:"#groupList", helper: 'clone', revert:true, revertDuration:'1' });
	
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
            window.AppController.setBrightness_selectString_(brightnessValue,getSelectedLights());
        break;
        case "right":
            value = $("#centerRightDisplay").height() * ( 1 - value);
            $("#centerRightDisplay > .modifier").animate({ height: value },animateSpeed);
        break;
	}
	
}

function LightDropOnGroup() {
	//var numLights = 0;
	var numLights = $("#lightList > .selected").length;
	//window.AppController.showMessage_(""+numLights);
	window.AppController.showMessage_("inside");
	$("#lightList > .selected").each(function(){
        var lightName = $(this).text();
        window.AppController.showMessage_(""+lightName);
    });
	
	//$("#AnimationsLeft").append("<div class='animation'>Animation "+numofAnimations+"<img class='animationControlRemove' src='removeAnimation.png'/></div>");
	
}

function getSelectedLights() {

	var selected = "g";
	$("#filterList > .selected").each(function(){
		selected += ","+$(this).html();
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
	return selected;
}

function getSelectedLightsForGroup() {

    selected = "";

    $(".light").each(function(index) {
        if($(this).hasClass("selected")){
            selected += index + ",";
        }
    });
    selected = selected.substring(0, selected.length-1);;
    //window.AppController.showMessage_(selected);
    return selected;
}
