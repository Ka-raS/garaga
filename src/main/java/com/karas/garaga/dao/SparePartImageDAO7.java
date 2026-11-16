package com.karas.garaga.dao;

import com.karas.garaga.model.SparePartImage7;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public final class SparePartImageDAO7 extends DAO7 {
    public SparePartImageDAO7() throws SQLException {
        super();
    }

    public SparePartImage7 getImage(long sparePartId, int ordinal) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("""
                SELECT ordinal, content_type, data
                FROM tbl_spare_part_image7
                WHERE spare_part7_id = ? AND ordinal = ?
                """)) {
            ps.setLong(1, sparePartId);
            ps.setInt(2, ordinal);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? new SparePartImage7(rs.getInt("ordinal"), rs.getString("content_type"), rs.getBytes("data"))
                        : null;
            }
        }
    }
}
