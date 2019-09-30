package com.lhn.chatroom.Service.Impl;

import com.lhn.chatroom.Dao.UserDao;
import com.lhn.chatroom.Entity.User;
import com.lhn.chatroom.Service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


/**
 * Created by mac on 2019/2/26.
 */
@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserDao userDao;

    @Override
    public User login(String name, String password) {
        User user = userDao.getByName(name);
        if (user.getPassword().equals(password)) {
            return user;
        }
        return null;
    }

    @Override
    public boolean register(User user) {
        int cnt = userDao.registerByName(user);
        System.out.println(cnt);
        if (cnt > 0) {
            return true;
        } else {
            return false;
        }
    }
}
