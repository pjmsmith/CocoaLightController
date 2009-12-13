var loopActive = false;
var playActive = false;


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
	   if (e.which == 117) { //u
	   window.AppController.setColor_("yellow");			
		} 
		if (e.which == 105) { //i
		   window.AppController.setColor_("green");			
		} 
		if (e.which == 111) { //o
			window.AppController.setColor_("cyan");			
		} 
		if (e.which == 106) { //j
			window.AppController.setColor_("red");			
		}
		if (e.which == 107) { //k
			window.AppController.setColor_("magenta");			
		} 
		if (e.which == 108) { //l
			window.AppController.setColor_("blue");			
		}  
	});

	$(".colorButton").click(function(){
		var color = $(this).attr("id"); 
		//window.AppController.showMessage_(color);
		window.AppController.setColor_(color);
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
			$("#AnimationsLeft").append("<div class='animation'>Animation x</div>");
			
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


	$("#AnimationsRight").sortable({ cursor: 'move', opacity: 0.6, containment: 'window' });
	$("#AnimationsLeft").sortable({ cursor: 'move', opacity: 0.6, containment: 'window' });

	$(".physicalButtons").droppable({
		drop: function() { 
			window.AppController.showMessage_("physical buttons");
		},
		hoverClass: 'droppableHover',
		tolerance: 'pointer'
	});


	$(function() {
	  $("#slider").slider({ min: 0, max:255, step: 15,value:255});
	});	

	$("#slider").bind('slide', function(event, ui) {
		//var value = $("#slider").slider('option', 'value');
		var value = ui.value;			  
		if (value > 255) {
					  value = 255;
		}
		$("#brightnessSliderInput").attr("value",value);
		window.AppController.setBrightness_(value);

	});
	
				  
	$("#dialog").dialog({ resizable: false, 
						   buttons: { 
								"Save": function() { 
											$(this).dialog("close");
											var lightName = $("input[name='lightName']").attr("value");
											var channelNumber = $("select[name='lightChannels']").attr("value");
											var channelNames = $("input[name='ch1']").attr("value");
											for (i=2;i<=channelNumber;i++) {
											var selector = "ch"+i;
											channelNames = channelNames + ","+$("input[name="+selector+"]").attr("value");
											}
											//window.AppController.showMessage_(""+lightName+","+channelNumber+channelNames);
											window.AppController.addLight_(lightName, channelNumber,channgleNames);

										},
								"Cancel":function() {
											$(this).dialog("close");
										}
							} 
						});


				  $("#addLightButton").click(function() {
											 $("#dialog").dialog('open');
				});
				  
				  });
