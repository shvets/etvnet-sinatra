$(document).ready(function() {
  $("#start_watching").click(function() {
    startWatching();
  });
});

function startWatching(params) {
  $.ajax({
    type: "POST",
    url:  "/access",
//    data: "skin=JSON&action=start_video&media_file=383941&bitrate=600&replay=1",
//    contentType: "application/x-www-form-urlencoded; charset=UTF-8",

////Cookie:	__utma=140009447.784949732.1256354384.1264856211.1264872090.91; __utmz=140009447.1263435195.48.5.utmccn=(organic)|utmcsr=google|utmctr=etvnet|utmcmd=organic; AWSUSER_ID=awsuser_id1256354384277r1296; adsystem=sarafan_root; lp=http%3A%2F%2Fwww.etvnet.ca%2F; referer=; visitor_id=10637517; last_login=1264872110; prev_login=1264856221; username=alex_shvets; demo=; demo2=; notp=; t7d=1; bblastvisit=1261974178; bblastactivity=0; auth=13464865522765420; AWSSESSION_ID=awssession_id1264871965137r8220; __utmb=140009447; __utmc=140009447; t1h=1

//    },
    success : function(result) {
      //alert("success: " + getContentInBetween(result, "REDIRECT_URL", "USER_ID"));
      //alert("result: " + result);
      $("#mms_url").html("<a href=" + result + ">MMS Link</a>")
    },
    complete : function(result, status) {
     //alert("complete " + status);
      //alert("result " + result);
    },
    error:function (xhr, ajaxOptions, thrownError){
//          alert("error status: " + xhr.status);
//                          alert(xhr.responseText);
          //alert(thrownError);
      }
  });
}

