package com.lhn.chatroom.Service;

import com.lhn.chatroom.Entity.User;

/**
 * Created by mac on 2019/2/26.
 */
public interface UserService {
    /**
     * 通过name,password进行登录
     * @param name
     * @param password
     * @return登录成功返回User，否则返回null
     */
    User login(String name, String password);

    /**
     * 通过name,password进行注册
     * @param user
     * @return注册成功返回true，否则返回false
     */
    boolean register(User user);
}
