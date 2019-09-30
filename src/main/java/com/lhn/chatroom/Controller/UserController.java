package com.lhn.chatroom.Controller;

import com.lhn.chatroom.Entity.User;
import com.lhn.chatroom.Service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;

/**
 * Created by mac on 2019/2/26.
 */
@Controller
@RequestMapping(value = "/user")
public class UserController {

    @Autowired
    private UserService userService;


    /**
     * 登录判断，登录正确进入聊天室，失败重新登录
     *
     * @param name,password,session
     */
    @RequestMapping("/login")
    public String login(String name, String password, HttpSession session) {
        try {
            User user = userService.login(name, password);
            if (user != null) {
                //设置当前session的名称
                session.setAttribute("username", name);
                //重定向
                return "redirect:/user/chatroom";
            } else {
                session.setAttribute("msg", "密码错误!");
                return "login";
            }
        }catch (Exception e){
            session.setAttribute("msg", "用户名不存在!");
            return "login";
        }
    }


    /**
     * 登录成功，进入聊天室
     */
    @RequestMapping("/chatroom")
    public String chatroom() {
        return "index";
    }

    /**
     * 注册提交，注册成功跳转登录界面，失败重新注册
     *
     * @param user,model
     */
    @RequestMapping("/submit")
    public String submit(User user, Model model) {
        try {
            if (user.getName().equals("") || user.getPassword().equals("")) {
                model.addAttribute("msg", "用户名密码不能为空！");
                return "register";
            }
            boolean flag = userService.register(user);
            if (flag) {
                model.addAttribute("msg","注册成功");
                return "login";
            } else {
                model.addAttribute("msg", "用户名已存在！");
                return "register";
            }
        } catch (Exception e) {
            model.addAttribute("msg", "注册失败！");
            return "register";
        }
    }
}
