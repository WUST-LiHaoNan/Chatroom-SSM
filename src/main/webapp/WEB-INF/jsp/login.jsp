<%--
  Created by IntelliJ IDEA.
  User: mac
  Date: 2019-02-24
  Time: 20:08
  To change this template use File | Settings | File Templates.
--%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%String path = request.getContextPath();%>
<!DOCTYPE html>
<html>
<head lang="en">
    <title>Login Page | Amaze UI Example</title>
    <jsp:include page="include/commonfile.jsp"/>
    <style>
        .header {
            text-align: center;
        }

        .header h1 {
            font-size: 200%;
            color: #333;
            margin-top: 30px;
        }

        .header p {
            font-size: 14px;
        }
    </style>
</head>
<body>
<div class="header">
    <div class="am-g">
        <h1>登录</h1>
    </div>
</div>
<div class="am-g">
    <div class="am-u-lg-6 am-u-md-8 am-u-sm-centered">
        <br>
        <br>
        <form action="<%=path%>/user/login" method="post" class="am-form">
            <label for="username">用户名:</label>
            <input type="text" name="name" id="username" value="">
            <br>
            <label for="password">密码:</label>
            <input type="password" name="password" id="password" value="">
            <br>
            <label for="remember-me">
                <input id="remember-me" type="checkbox">
                记住密码
            </label>
            <br/>
            <div class="am-cf">
                <input type="submit" name="" value="登 录" class="am-btn am-btn-primary am-btn-sm am-fl">
                <input type="button" name="" value="注 册" class="am-btn am-btn-default am-btn-sm am-fr"
                       onclick="location.href='<%=path%>/toRegister'">
            </div>
        </form>
    </div>
</div>
<!--弹窗信息-->
<script>
    var msg = '${msg}';
    if (msg)
        alert(msg);
</script>
</body>
</html>
