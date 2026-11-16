package com.karas.garaga.dao;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import com.karas.garaga.model.SparePartImage7;
import java.nio.charset.StandardCharsets;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class TestSparePartImageDAO7 extends TestDAO7 {
    private SparePartImageDAO7 dao;
    private long brakePadId;

    @BeforeEach
    void createDAO() throws SQLException {
        dao = new SparePartImageDAO7();

        try (Statement st = DAO7.con.createStatement()) {
            try (ResultSet rs = st.executeQuery("""
                    INSERT INTO tbl_spare_part7 (barcode, name, unit, unit_price, stock_quantity)
                    VALUES ('8930000000021', 'Test7 rear brake pad set', 'set', 750000, 10)
                    RETURNING id
                    """)) {
                rs.next();
                brakePadId = rs.getLong("id");
            }

            st.executeUpdate("""
                    INSERT INTO tbl_spare_part_image7 (ordinal, content_type, data, spare_part7_id)
                    SELECT i.ordinal, i.content_type, convert_to(i.data, 'UTF8'), p.id
                    FROM (VALUES (0, 'image/png', 'a'), (1, 'image/jpeg', 'b'))
                        AS i (ordinal, content_type, data)
                    JOIN tbl_spare_part7 p ON p.barcode = '8930000000021'
                    """);
        }
    }

    @Test
    void getImageReturnsTheImageData() throws SQLException {
        final SparePartImage7 image = dao.getImage(brakePadId, 1);

        assertEquals(1, image.ordinal());
        assertEquals("image/jpeg", image.contentType());
        assertArrayEquals("b".getBytes(StandardCharsets.UTF_8), image.data());
    }

    @Test
    void getImageReturnsNullWhenTheImageDoesNotExist() throws SQLException {
        assertNull(dao.getImage(brakePadId, 2));
        assertNull(dao.getImage(-1, 1));
    }
}
