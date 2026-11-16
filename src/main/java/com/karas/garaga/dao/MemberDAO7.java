package com.karas.garaga.dao;

import com.karas.garaga.model.Customer7;
import com.karas.garaga.model.ManagementStaff7;
import com.karas.garaga.model.Member7;
import com.karas.garaga.model.SaleStaff7;
import com.karas.garaga.model.StaffInfo7;
import com.karas.garaga.model.WarehouseStaff7;
import java.security.GeneralSecurityException;
import java.security.MessageDigest;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.Base64;
import java.util.Locale;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public final class MemberDAO7 extends DAO7 {
    public MemberDAO7() throws SQLException {
        super();
    }

    public Member7 checkLogin(Member7 member) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("""
                SELECT m.id, m.username, m.password_hashed,
                       c.fullname AS customer_fullname, c.phone_number AS customer_phone_number,
                       s.id AS staff_id, s.fullname AS staff_fullname, s.phone_number AS staff_phone_number,
                       s.email AS staff_email, s.birth_date AS staff_birth_date, s.position AS staff_position
                FROM tbl_member7 m
                LEFT JOIN tbl_customer7 c ON c.member7_id = m.id
                LEFT JOIN tbl_staff7 s ON s.member7_id = m.id
                WHERE m.username = ?
                  AND (c.member7_id IS NOT NULL OR s.position <> 'TECHNICAL')
                """)) {
            ps.setString(1, member.username().strip().toLowerCase(Locale.ROOT));

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next() || !verifyPassword(member.password(), rs.getString("password_hashed"))) {
                    return null;
                }

                final long id = rs.getLong("id");
                final String username = rs.getString("username");
                if (rs.getString("customer_fullname") != null) {
                    return new Customer7(id, username, rs.getString("customer_fullname"),
                            rs.getString("customer_phone_number"));
                }

                final StaffInfo7 info = new StaffInfo7(rs.getLong("staff_id"), rs.getString("staff_fullname"),
                        rs.getString("staff_phone_number"), rs.getString("staff_email"),
                        rs.getObject("staff_birth_date", LocalDate.class));

                return switch (rs.getString("staff_position")) {
                    case "SALE" -> new SaleStaff7(id, username, info);
                    case "WAREHOUSE" -> new WarehouseStaff7(id, username, info);
                    case "MANAGEMENT" -> new ManagementStaff7(id, username, info);
                    default -> throw new IllegalStateException("Unknown staff position of member " + id);
                };
            }
        }
    }

    private static boolean verifyPassword(String password, String passwordHashed) {
        final String[] parts = passwordHashed.split("\\$");
        if (parts.length != 4 || !parts[0].equals("pbkdf2_sha256")) {
            return false;
        }

        final byte[] expected = Base64.getDecoder().decode(parts[3]);
        final PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), Base64.getDecoder().decode(parts[2]),
                Integer.parseInt(parts[1]), expected.length * Byte.SIZE);

        try {
            return MessageDigest.isEqual(expected,
                    SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256").generateSecret(spec).getEncoded());
        } catch (GeneralSecurityException e) {
            throw new IllegalStateException(e);
        } finally {
            spec.clearPassword();
        }
    }
}
