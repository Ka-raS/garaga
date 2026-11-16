package com.karas.garaga.dao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNull;

import com.karas.garaga.model.Customer7;
import com.karas.garaga.model.Member7;
import com.karas.garaga.model.WarehouseStaff7;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class TestMemberDAO7 extends TestDAO7 {
    private static final String PASSWORD_123456_HASHED =
            "pbkdf2_sha256$600000$ZIZDcX5rFr+6p5ptWzq2WQ$KUkR6V5Q7o2FCY2LZCVe+H3q0bkwufOvLuDTcuTyNB4";

    private MemberDAO7 dao;
    private long warehouseMemberId;
    private long warehouseStaffId;

    @BeforeEach
    void createDAO() throws SQLException {
        dao = new MemberDAO7();
        warehouseMemberId = insertMember("test7.warehouse", PASSWORD_123456_HASHED);
        warehouseStaffId = insertStaff(warehouseMemberId, "0000000711", "WAREHOUSE");

        try (PreparedStatement ps = DAO7.con.prepareStatement("""
                INSERT INTO tbl_customer7 (fullname, phone_number, member7_id)
                VALUES ('Test7 Customer', '0000000712', ?)
                """)) {
            ps.setLong(1, insertMember("test7.customer", PASSWORD_123456_HASHED));
            ps.executeUpdate();
        }
    }

    private static long insertMember(String username, String passwordHashed) throws SQLException {
        try (PreparedStatement ps = DAO7.con.prepareStatement("""
                INSERT INTO tbl_member7 (username, password_hashed)
                VALUES (?, ?)
                RETURNING id
                """)) {
            ps.setString(1, username);
            ps.setString(2, passwordHashed);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong("id");
            }
        }
    }

    private static long insertStaff(long memberId, String phoneNumber, String position) throws SQLException {
        try (PreparedStatement ps = DAO7.con.prepareStatement("""
                INSERT INTO tbl_staff7 (fullname, phone_number, email, birth_date, position, member7_id)
                VALUES ('Test7 Staff', ?, ? || '@test7.vn', '1995-03-08', ?::enum_staff_position7, ?)
                RETURNING id
                """)) {
            ps.setString(1, phoneNumber);
            ps.setString(2, phoneNumber);
            ps.setString(3, position);
            ps.setLong(4, memberId);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong("id");
            }
        }
    }

    @Test
    void checkLoginReturnsWarehouseStaffWithStaffInfo() throws SQLException {
        final WarehouseStaff7 staff = assertInstanceOf(WarehouseStaff7.class,
                dao.checkLogin(new Member7("test7.warehouse", "123456")));
        assertEquals(warehouseMemberId, staff.id());
        assertEquals("test7.warehouse", staff.username());
        assertNull(staff.password());
        assertEquals(warehouseStaffId, staff.info().id());
        assertEquals("Test7 Staff", staff.info().fullname());
        assertEquals("0000000711", staff.info().phoneNumber());
        assertEquals("0000000711@test7.vn", staff.info().email());
        assertEquals(LocalDate.of(1995, 3, 8), staff.info().birthDate());
    }

    @Test
    void checkLoginReturnsCustomer() throws SQLException {
        final Customer7 customer = assertInstanceOf(Customer7.class,
                dao.checkLogin(new Member7("test7.customer", "123456")));
        assertEquals("Test7 Customer", customer.fullname());
        assertEquals("0000000712", customer.phoneNumber());
    }

    @Test
    void checkLoginIgnoresUsernameCaseAndSurroundingSpaces() throws SQLException {
        assertInstanceOf(WarehouseStaff7.class, dao.checkLogin(new Member7("  TEST7.WareHouse ", "123456")));
    }

    @Test
    void checkLoginReturnsNullForWrongPassword() throws SQLException {
        assertNull(dao.checkLogin(new Member7("test7.warehouse", "654321")));
    }

    @Test
    void checkLoginReturnsNullForUnknownUsername() throws SQLException {
        assertNull(dao.checkLogin(new Member7("test7.nobody", "123456")));
    }

    @Test
    void checkLoginReturnsNullForTechnicalStaff() throws SQLException {
        insertStaff(insertMember("test7.technician", PASSWORD_123456_HASHED), "0000000713", "TECHNICAL");

        assertNull(dao.checkLogin(new Member7("test7.technician", "123456")));
    }

    @Test
    void checkLoginReturnsNullWhenThePasswordIsStoredAsPlainText() throws SQLException {
        insertStaff(insertMember("test7.plaintext", "123456"), "0000000714", "WAREHOUSE");

        assertNull(dao.checkLogin(new Member7("test7.plaintext", "123456")));
    }
}
