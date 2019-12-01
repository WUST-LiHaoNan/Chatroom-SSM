package chatroom.service;

import chatroom.BaseTest;
import com.lhn.chatroom.Entity.User;
import com.lhn.chatroom.Service.UserService;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;

import javax.annotation.Resource;

/**
 * Created by lhn on 2017/3/3.
 */
public class UserServiceTest extends BaseTest{
    @Resource
    UserService userService;

    @Test
    public void testLogin(){
        User user = userService.login("lihaonan","123456");
        System.out.println(user.toString());
    }
}
