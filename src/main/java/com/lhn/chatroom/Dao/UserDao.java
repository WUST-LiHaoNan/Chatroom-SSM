package com.lhn.chatroom.Dao;

import com.lhn.chatroom.Entity.User;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * Created by lhn on 2017/3/1.
 */
@Repository
public interface UserDao {
    /**
     * 根据id获得用户信息
     * @param id
     * @return
     */
    User getById(int id);

    /**
     * 根据name获得用户信息
     * @param name
     * @return
     */
    User getByName(String name);

    /**
     * 用户注册
     * @param user
     * @return
     */
    int registerByName(User user);

    /**
     * 获取全部用户信息
     * @param
     * @return
     */
    List<User> getAllUser();

    /**
     * 获取用户Map信息
     * @param id
     * @return
     */
    Map<String,Object> getUser(int id);
}
