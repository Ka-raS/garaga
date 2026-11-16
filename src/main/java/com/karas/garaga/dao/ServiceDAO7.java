package com.karas.garaga.dao;

import com.karas.garaga.model.Service7;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Duration;
import java.util.ArrayList;

public final class ServiceDAO7 extends DAO7 {
    public ServiceDAO7() throws SQLException {
        super();
    }

    public ArrayList<Service7> searchServices(String keyword, int limit, int offset) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("""
                SELECT id, name, price, duration_minutes, description, available
                FROM tbl_service7
                WHERE available AND name ILIKE '%' || ? || '%'
                ORDER BY name, id
                LIMIT ? OFFSET ?
                """)) {
            ps.setString(1, keyword);
            ps.setInt(2, limit);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                final ArrayList<Service7> services = new ArrayList<>();
                while (rs.next()) {
                    final Integer minutes = rs.getObject("duration_minutes", Integer.class);
                    services.add(new Service7(rs.getLong("id"), rs.getString("name"), rs.getBigDecimal("price"),
                            minutes == null ? null : Duration.ofMinutes(minutes), rs.getString("description"),
                            rs.getBoolean("available")));
                }

                return services;
            }
        }
    }
}
