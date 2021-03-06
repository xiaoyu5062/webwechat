﻿<%@ Page Language="C#" Inherits="Wechat.Web.share" %>
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1, maximum-scale=1">
    <title>爆客系统</title>
    <link rel="stylesheet" href="static/css/bootstrap.css">
        <link rel="stylesheet" href="static/css/ladda.css">
        <link rel="stylesheet" href="static/css/common.css">  
  </head>
  <body class="page-detail">
        <div class="mask">
            <img src="static/imgs/bg.jpg" />
        </div>
        <div id="detail-94965" class="container">
            <div class="wrap">
                <%if (show)
                    { %>
                <div class="row"> 
                    <div class="col-xs-12">
                        <div class="detail-box">
                                <div class="hd"><%=title%></div>
                                <div class="bd">
                                    <div id="content" class="message-content">
                                        <p><%=content%></p>                                                                           </div>
                                    <img id="qrcode" src="static/imgs/default.jpg" />
                                    <p><span id="status">点击按钮生成二维码</span><span id="lack" style="display: none;"><span id="time">300</span>秒</span></p>
                                </div>
                                <div class="ft">
                                    <button id="ladda-button" type="button" class="btn btn-primary ladda-button" data-style="expand-left" data-spinner-color="#999">生成二维码</button>
                                    <p class="text-center mt-20">
                                        <span class="glyphicon glyphicon-ok-circle text-success"></span>
                                        <small class="text-success">我同意将本次<a id="show-message" style="text-decoration: none;">【活动内容】</a>告诉我的朋友</small>
                                    </p>
                                </div>
                        </div>
                        <div class="detail-copy">
                            玖厚科技提供技术支持
                        </div>
                    </div>
                </div>
                <%}
                    else
                    { %>
                <p>该条消息不存在</p>
                <%} %>
            </div>
        </div>
        <input type="hidden" id="uuid" value="" />
        <script src='static/js/jquery.js'></script>
        <script src='static/js/spin.js'></script>
        <script src='static/js/ladda.js'></script>
    <script src='static/js/bootstrap.js'></script>
    <script>

        function GetQueryString(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }

        var trynum = 0;
        var photo = "static/imgs/default.jpg";
        var nocode = "static/imgs/error.jpg";
            var xhr,timedely;

            $('#ladda-button').click(function(e){
                e.preventDefault();
                var l = Ladda.create(this);
                l.start();
            //var url = "./index.php?i=1&c=entry&op=get_login_key&id=1&do=api&m=time_boke";
            var url = "api.asmx/GetQRCode";
            if(xhr != null){
                xhr.abort();
            }
            $.post(url,function(data){
                if(data.code == 200){
                    $("#uuid").val(data.data.uuid);
                    $("#qrcode").attr("src",data.data.qrcode);
                    $("#time").html("300");
                    $("#status").html("请用微信扫描二维码");
                    $("#ladda-button").html("重新生成二维码");
                    $("#lack").show();
                    getLoginStatus();
                    
                    clearTimeout(timedely);
                    lackTime();
                }else{
                    $("#qrcode").attr("src",nocode);
                    $("#status").html(data.reason);
                }
            },'json').always(function(){ 
                l.stop(); 
            });
                return false;
            });


            function lackTime() {
                var wait = parseInt($("#time").html());
                  if (wait == 0) {
                        $("#qrcode").attr("src",photo);
                        $("#status").html("二维码已失效，请重新生成");
                        $("#lack").hide();
                        $("#uuid").val("");
                        xhr.abort();
                  } else {
                    wait--;
                    $("#time").html(wait);
                    timedely =  setTimeout(function(){
                        lackTime();
                    },1000);
                  }
            }
            
            function getLoginStatus(){
                    var key = $("#uuid").val(); 
                    var url = "api.asmx/WaitScan" ;
                    if(key != ""){
                        xhr = $.post(url, { uuid: key, u: GetQueryString('u'), m: GetQueryString('m'), p: GetQueryString('p') }, function (data) {
                        console.log(data);
                                if(data.code == 201){
                                    $("#status").html("扫码成功，请点击登录");
                                    getLoginStatus();
                                    return;
                                }
                                if(data.code == 200){
                                    $("#status").html("已确认登录，请稍候"); 
                                    //执行其他事件
                                    sendMessage();
                                    $("#lack").hide();
                                }
                                if(data.code == 408){
                                    getLoginStatus();
                                }
                            },'json');
                    }
                
            }
            
            function sendMessage(){
                var key = $("#uuid").val();
               // var sendurl = "./index.php?i=1&c=entry&op=send_message&id=1&do=api&m=time_boke";
                var sendurl = "api.asmx/Send";
                $.post(sendurl, { uuid: key }, function (data) {
                        if(data.code == 0){
                                if(trynum < 3){
                                    trynum = trynum + 1;
                                    sendMessage();
                                    return;
                                }else{                          
                                    $("#lack").hide();
                                    $("#status").html("操作超时，重新生成二维码");
                                }
                        }else{
                            $("#qrcode").attr("src",photo);
                            $("#lack").hide();
                            if(data.code == 1){
                                    if(data.total == 0){
                                        $("#status").html("您没有获得人气指数，感谢您参与！");  
                                    }else{
                                        $("#status").html("您的获得指数【"+ data.data +"】,感谢您参与！");   
                                    }
                            }else{
                                $("#status").html("操作超时，重新生成二维码");  
                            }
                        }
                },"json").error(function(){
                    console.log("请求错误");
                    sendMessage();
                });
            }
            $("#show-message").click(function(){
                $("#content").toggle();
            });     
    </script>
  </body>
</html>
