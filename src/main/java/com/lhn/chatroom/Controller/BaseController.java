package com.lhn.chatroom.Controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * Created by mac on 2019/2/26.
 */
@Controller("/")
public class BaseController {
    /**
     * 跳转登录界面
     */
    @RequestMapping(value = "login")
    public String login() {
        return "login";
    }

    /**
     * 跳转注册界面
     */
    @RequestMapping("toRegister")
    public String registerIndex() {
        return "register";
    }
}
