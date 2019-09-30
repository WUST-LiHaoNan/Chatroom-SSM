<%--
  Created by IntelliJ IDEA.
  User: mac
  Date: 2019-02-24
  Time: 21:58
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="utf-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>Chatroom|聊天室</title>
    <jsp:include page="include/commonfile.jsp"/>
</head>
<body>
<jsp:include page="include/header.jsp"/>
<!-- content start -->
<div class="admin-content">
    <div class="" style="width: 80%;float:left;">
        <!-- 聊天区 -->
        <div class="am-scrollable-vertical" id="chat-view" style="height: 450px;">
            <ul class="am-comments-list" id="chat">
            </ul>
        </div>
        <!-- 输入区 -->
        <div class="am-form-group am-form">
            <textarea class="" id="message" name="message" rows="5" placeholder="这里输入你想发送的信息..."></textarea>
        </div>
        <%--预览区--%>
        <div class="" style="float:left;">
            <input type="file" id="img"> 预览：<img id="imgShow" src="" alt="">
        </div>
        <br>
        <!-- 接收者 -->
        <div class="" style="float: left">
            <p class="am-kai">发送给 : <span id="sendto">全体成员</span>
                <button class="am-btn am-btn-xs am-btn-danger" onclick="$('#sendto').text('全体成员')">复位</button>
            </p>
        </div>
        <!-- 按钮区 -->
        <div class="am-btn-group am-btn-group-xs" style="float:right;">
            <button class="am-btn am-btn-default" type="button" onclick="clear()"><span
                    class="am-icon-trash-o"></span> 清屏
            </button>
            <button class="am-btn am-btn-default" type="button" onclick="checkConnection()"><span
                    class="am-icon-bug"></span> 检查
            </button>
            <button class="am-btn am-btn-default" type="button" onclick="sendMessage()"><span
                    class="am-icon-commenting"></span> 发送
            </button>
            <button class="am-btn am-btn-default" type="button" onclick="uploadImage()"><span
                    class="am-icon-file-image-o"></span> 上传图片
            </button>
            <button class="am-btn am-btn-default" type="button" onclick="sendImage()"><span
                    class="am-icon-file-image-o"></span> 发送图片
            </button>
        </div>
    </div>
    <!-- 列表区 -->
    <div class="am-panel am-panel-default" style="float:right;width: 20%;">
        <div class="am-panel-hd">
            <h3 class="am-panel-title">在线列表 [<span id="onlinenum"></span>]</h3>
        </div>
        <ul class="am-list am-list-static am-list-striped" id="list">
        </ul>
    </div>
</div>
<!-- content end -->
<script>

    //base64类型的图片数据
    var imgData = null;
    var ws = null;
    //判断当前浏览器是否支持WebSocket
    if ('WebSocket' in window) {
        ws = new WebSocket("ws://" + location.host + "${pageContext.request.contextPath}" + "/ChatServer");
    } else {
        alert("对不起！你的浏览器不支持webSocket")
    }

    //连接成功建立的回调方法
    ws.onopen = function (event) {
        setMessageInnerHTML("系统消息：加入连接");
    };
    //收到后台消息进行分析
    ws.onmessage = function (event) {
        //解析后台传回的消息,并予以展示
        analysisMessage(event.data);
    };
    //连接关闭的回调方法
    ws.onclose = function (e) {
        console.log(e);
        setMessageInnerHTML("系统消息：断开连接");
    };
    //连接发生错误的回调方法
    ws.onerror = function () {
        setMessageInnerHTML("系统消息：error");
    };

    /**
     *监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，避免抛出异常
     */
    window.onbeforeunload = function () {
        var is = confirm("确定关闭窗口？");
        if (is) {
            ws.close();
        }
    };

    /**
     * 关闭连接
     */
    //关闭连接
    function closeWebSocket() {
        ws.close();
    }

    /**
     * 检查当前连接状态
     */
    function checkConnection() {
        if (ws != null) {
            alert(ws.readyState == 0 ? "连接异常" : "连接正常", {offset: 0});
        } else {
            alert("连接未开启!", {offset: 0, shift: 6});
        }
    }

    /**
     * 转发消息给后台
     */
    function sendMessage() {
        //获取输入框的文本信息
        var message = $("#message").val();
        //获取接收方
        var to = $("#sendto").text() == "全体成员" ? "" : $("#sendto").text();
        //判断发送消息是否为空
        if (!message) {
            alert("发送信息不能为空！");
            return;
        }
        //将消息转化为JSNO进行传递
        var msgJSON = JSON.stringify({
            message: {
                //输入框的内容
                content: message,
                //登录成功后保存在Session.attribute中的username
                from: '${username}',
                //接收人,如果没有则置空,如果有多个接收人则用逗号分隔
                to: to
            },
            type: "message"
        });
        //发送信息
        ws.send(msgJSON);
    }

    /**
     * 发送图片给后台
     */
    function sendImage() {
        //获取接收方
        var to = $("#sendto").text() == "全体成员" ? "" : $("#sendto").text();
        //判断图片是否上传
        if (!imgData) {
            alert("图片未上传！");
            return;
        }
        //将图片信息转化为JSON进行传递
        var imgJSON = JSON.stringify({
            message: {
                //图片的base64类型字符串
                content: imgData,
                //登录成功后保存在Session.attribute中的username
                from: '${username}',
                //接收人,如果没有则置空,如果有多个接收人则用逗号分隔
                to: to
            },
            type: "image"
        });
        //发送信息
        ws.send(imgJSON);
    }

    /**
     * 解析后台传来的消息
     * JSON格式如下
     * "message" : {
     *              "from" : "xxx",
     *              "to" : "xxx",
     *              "content" : "xxx"
     *          },
     * "type" : {notice|message},
     * "list" : {[xx],[xx],[xx]}
     */
    function analysisMessage(message) {
        message = JSON.parse(message);
        //会话消息
        if (message.type == "message") {
            showChat(message.message);
        }
        //系统提示消息
        if (message.type == "notice") {
            showNotice(message.message);
        }
        //图片消息
        if (message.type == "image") {
            showImage(message.message);
        }
        //在线列表
        if (message.list != null && message.list != undefined) {
            showOnline(message.list);
        }
    }

    /**
     * 展示会话信息
     */
    function showChat(message) {
        //获取接收人
        var to = message.to == null || message.to == "" ? "全体成员" : message.to;
        var html = message.from + " 发送给: " + to + "\n" + message.content + "<br/>";
        $("#chat").append(html);
        //清空输入区
        $("#message").val("");
        var chat = $("#chat-view");
        //让聊天区始终滚动到最下面
        chat.scrollTop(chat[0].scrollHeight);
    }

    /**
     * 展示提示信息
     */
    function showNotice(notice) {
        $("#chat").append("<div><p class=\"am-text-success\" style=\"text-align:center\"><span class=\"am-icon-bell\"></span> " + notice + "</p></div>");
        var chat = $("#chat-view");
        //让聊天区始终滚动到最下面
        chat.scrollTop(chat[0].scrollHeight);
    }

    /**
     * 展示图片信息
     */
    function showImage(image) {
        //获取图片编码
        var imgdata = image.content;
        //获取接收人
        var to = image.to == null || image.to == "" ? "全体成员" : image.to;
        var html = image.from + " 发送给: " + to + "\n" + "<img src=" + imgdata + ">" + "<br>";
        $("#chat").append(html);
        //清空输入区
        $("#message").val("");
        //清空上传的图片
        $("#img").val("");
        //清空base64类型的图片数据
        $("#imgdata").val("");
        var imgShow = document.getElementById('imgShow');
        //清空预览图片信息
        imgShow.setAttribute('src', "");
        var chat = $("#chat-view");
        //让聊天区始终滚动到最下面
        chat.scrollTop(chat[0].scrollHeight);
    }

    /**
     * 展示在线列表
     */
    function showOnline(list) {
        //清空在线列表
        $("#list").html("");
        //添加私聊按钮
        $.each(list, function (index, item) {
            var li = "<li>" + item + "</li>";
            //排除自己
            if ('${username}' != item) {
                li = "<li>" + item + " <button type=\"button\" class=\"am-btn am-btn-xs am-btn-primary am-round\" onclick=\"addChat('" + item + "');\"><span class=\"am-icon-phone\"><span> 私聊</button></li>";
            }
            $("#list").append(li);
        });
        //获取在线人数
        $("#onlinenum").text($("#list li").length);
    }

    /**
     * 添加接收人
     */
    function addChat(user) {
        var sendto = $("#sendto");
        var receive = sendto.text() == "全体成员" ? "" : sendto.text() + ",";
        //排除重复
        if (receive.indexOf(user) == -1) {
            sendto.text(receive + user);
        }
    }

    /**
     * 清空聊天区
     */
    function clear() {
        $("#chat").html("");
    }

    /**
     * 发送系统消息
     * @param innerHTML
     */
    function setMessageInnerHTML(innerHTML) {
        $("#chat").append(innerHTML + "<br/>")
    };

    /**
     * 上传图片
     * 使用FileReader对象将本地图片转换为base64发送给服务端
     */

    function uploadImage() {
        var img = document.getElementById('img')
            , imgShow = document.getElementById('imgShow')
            , message = document.getElementById('message')
        var imgFile = new FileReader();
        //获取文件字节流
        imgFile.readAsDataURL(img.files[0]);
        //获取文件类型
        var suffix = img.files[0].type;
        //获取文件后缀名
        var type = suffix.substr(6);
        if(type!="jpeg"&&type!="gif"&&type!="bmp"&&type!="png"){
            alert("当前文件格式不支持!");
            //清空上传图片
            $("#img").val("");
            return;
        }
        imgFile.onload = function () {
            //base64数据
            imgData = this.result;
            //预览图片
            imgShow.setAttribute('src', imgData);
        }
    }

</script>
</body>
</html>

