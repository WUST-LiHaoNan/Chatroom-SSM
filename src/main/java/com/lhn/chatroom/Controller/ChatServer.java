package com.lhn.chatroom.Controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;

import javax.servlet.http.HttpSession;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * Created by mac on 2019/2/26.
 */
@ServerEndpoint(value = "/ChatServer", configurator = HttpSessionConfigurator.class)
public class ChatServer {
    //静态变量，记录当前在线人数，应该将他设计为线程安全的
    private static int onlineCount = 0;
    //线程连接池
    private static CopyOnWriteArraySet <ChatServer> webSocketSet = new CopyOnWriteArraySet <ChatServer>();
    //与某个客户端的连接会话，需要通过它来给客户端发送数据
    private Session session;
    //用户名
    private String username;
    //request的session
    private HttpSession httpSession;
    //在线列表,记录用户名称
    private static List list = new ArrayList <>();
    //用户名和websocket的session绑定的路由表
    private static Map routetab = new HashMap <>();

    /**
     * 连接建立成功调用的方法
     *
     * @param session 可选的参数。session为与某个客户端的连接会话，需要通过它来给客户端发送数据
     */
    @OnOpen
    public void onOpen(Session session, EndpointConfig config) {
        this.session = session;
        //加入set中
        webSocketSet.add(this);
        //在线数加1;
        addOnlineCount();
        this.httpSession = (HttpSession) config.getUserProperties().get(HttpSession.class.getName());
        //获取当前用户
        this.username = (String) httpSession.getAttribute("username");
        //将用户名加入在线列表
        list.add(username);
        //将用户名和session绑定到路由表
        routetab.put(username, session);
        //系统自动组装初次登录消息
        String message = getMessage("[" + username + "]加入聊天室,当前在线人数为" + getOnlineCount() + "位", "notice", list);
        //向全体在线用户通知该用户上线
        broadcast(message);
    }

    /**
     * 连接关闭调用的方法
     */
    @OnClose
    public void onClose() {
        //从set中删除
        webSocketSet.remove(this);
        //在线数减1
        subOnlineCount();
        //从在线列表移除这个用户
        list.remove(username);
        //从路由表中移除该用户
        routetab.remove(username);
        //系统自动组装下线消息
        String message = getMessage("[" + username + "]离开了聊天室,当前在线人数为" + getOnlineCount() + "位", "notice", list);
        //向全体在线用户通知该用户下线
        broadcast(message);
    }

    /**
     * 接收客户端的message,判断是否有接收人而选择进行广播还是指定发送
     * "message" : {
     * "from" : "xxx",
     * "to" : "xxx",
     * "content" : "xxx",
     * "time" : "xxxx.xx.xx"
     * },
     * "type" : {notice|message|image},
     * "list" : {[xx],[xx],[xx]}
     *
     * @param _message 客户端发送过来的消息
     */
    @OnMessage
    public void onMessage(String _message) {
        //将收到数据转化为JSON数据
        JSONObject chat = JSON.parseObject(_message);
        //将消息内容转化为JSON数据
        JSONObject message = JSON.parseObject(chat.get("message").toString());
        System.out.println("传入的数据内容是：");
        System.out.println(message.get("content"));
        //如果to为空,则广播;如果不为空,则对指定的用户发送消息
        if (message.get("to") == null || message.get("to").equals("")) {
            broadcast(_message);
        } else {
            String[] userlist = message.get("to").toString().split(",");
            //发送给自己
            singleSend(_message, (Session) routetab.get(message.get("from")));
            for (String user : userlist) {
                if (!user.equals(message.get("from"))) {
                    //分别发送给每个指定用户
                    singleSend(_message, (Session) routetab.get(user));
                }
            }
        }
    }

    /**
     * 发生错误时调用
     *
     * @param error
     */
    @OnError
    public void onError(Throwable error) {
        error.printStackTrace();
    }

    /**
     * 广播消息
     *
     * @param message
     */
    public void broadcast(String message) {
        for (ChatServer chat : webSocketSet) {
            try {
                chat.session.getBasicRemote().sendText(message);
            } catch (IOException e) {
                e.printStackTrace();
                continue;
            }
        }
    }

    /**
     * 对特定用户发送消息
     *
     * @param message
     * @param session
     */
    public void singleSend(String message, Session session) {
        try {
            session.getBasicRemote().sendText(message);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 组装返回给前台的消息
     *
     * @param message 交互信息
     * @param type    信息类型
     * @param list    在线列表
     * @return
     */
    public String getMessage(String message, String type, List list) {
        JSONObject member = new JSONObject();
        member.put("message", message);
        member.put("type", type);
        member.put("list", list);
        return member.toString();
    }

    public int getOnlineCount() {
        return onlineCount;
    }

    public void addOnlineCount() {
        ChatServer.onlineCount++;
    }

    public void subOnlineCount() {
        ChatServer.onlineCount--;
    }
}
