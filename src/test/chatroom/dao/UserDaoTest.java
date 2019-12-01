package chatroom.dao;

import chatroom.BaseTest;
import com.lhn.chatroom.Dao.UserDao;
import com.lhn.chatroom.Entity.User;
import org.junit.Test;

import javax.annotation.Resource;

/**
 * Created by lhn on 2017/3/3.
 */

public class UserDaoTest extends BaseTest{
    @Resource
    UserDao userDao;

    @Test
    public void testGetById(){
        User user = userDao.getById(1);
        System.out.println(user.toString());
    }

    @Test
    public void testGetByName(){
        User user = userDao.getByName("yuanzhe");
        System.out.println(user.toString());
    }

    @Test
    public void testRegisterByName(){
        User user = new User();
        user.setName("Nick");
        user.setPassword("123456");
        int flag =userDao.registerByName(user);
        System.out.print(flag);
    }
}
