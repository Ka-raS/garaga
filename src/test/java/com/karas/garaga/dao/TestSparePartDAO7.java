package com.karas.garaga.dao;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.karas.garaga.model.SparePart7;
import com.karas.garaga.model.SparePartImage7;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class TestSparePartDAO7 extends TestDAO7 {
    private SparePartDAO7 dao;
    private long brakePadId;

    @BeforeEach
    void createDAO() throws SQLException {
        dao = new SparePartDAO7();

        try (Statement st = DAO7.con.createStatement()) {
            try (ResultSet rs = st.executeQuery("""
                    INSERT INTO tbl_spare_part7
                        (barcode, name, unit, producer, unit_price, stock_quantity, description)
                    VALUES ('8930000000007', 'Test7 front brake pad set', 'set', 'Test7 Producer',
                            850000, 10, 'Genuine front brake pads')
                    RETURNING id
                    """)) {
                rs.next();
                brakePadId = rs.getLong("id");
            }

            st.executeUpdate("""
                    INSERT INTO tbl_spare_part_image7 (ordinal, content_type, data, spare_part7_id)
                    SELECT i.ordinal, i.content_type, convert_to(i.data, 'UTF8'), p.id
                    FROM (VALUES (2, 'image/gif', 'c'), (0, 'image/png', 'a'), (1, 'image/jpeg', 'b'))
                        AS i (ordinal, content_type, data)
                    JOIN tbl_spare_part7 p ON p.barcode = '8930000000007'
                    """);
            st.executeUpdate("""
                    INSERT INTO tbl_spare_part7 (name, unit, unit_price, stock_quantity) VALUES
                        ('Test7 wiper blade B', 'piece', 320000, 20),
                        ('Test7 wiper blade A', 'piece', 320000, 20),
                        ('Test7 oil filter', 'piece', 150000, 0)
                    """);
        }
    }

    @Test
    void searchSparePartsReturnsAllFieldsWithOrderedImages() throws SQLException {
        final ArrayList<SparePart7> spareParts = dao.searchSpareParts("test7 front brake", 100, 0);
        assertEquals(1, spareParts.size());

        final SparePart7 sparePart = spareParts.getFirst();
        assertEquals(brakePadId, sparePart.id());
        assertEquals("8930000000007", sparePart.barcode());
        assertEquals("Test7 front brake pad set", sparePart.name());
        assertEquals("set", sparePart.unit());
        assertEquals("Test7 Producer", sparePart.producer());
        assertEquals(new BigDecimal("850000.00"), sparePart.unitPrice());
        assertEquals(10, sparePart.stockQuantity());
        assertEquals("Genuine front brake pads", sparePart.description());
        assertEquals(List.of(0, 1, 2), sparePart.images().stream().map(SparePartImage7::ordinal).toList());
        assertEquals(List.of("image/png", "image/jpeg", "image/gif"),
                sparePart.images().stream().map(SparePartImage7::contentType).toList());
        assertTrue(sparePart.images().stream().allMatch(image -> image.data() == null));
    }

    @Test
    void searchSparePartsIgnoresCaseAndSortsByName() throws SQLException {
        assertEquals(List.of("Test7 wiper blade A", "Test7 wiper blade B"),
                dao.searchSpareParts("TEST7 WIPER", 100, 0).stream().map(SparePart7::name).toList());
    }

    @Test
    void searchSparePartsReturnsTheRequestedPage() throws SQLException {
        assertEquals(List.of("Test7 wiper blade B"),
                dao.searchSpareParts("test7 wiper", 1, 1).stream().map(SparePart7::name).toList());
        assertTrue(dao.searchSpareParts("test7 wiper", 1, 2).isEmpty());
    }

    @Test
    void searchSparePartsReturnsEmptyImagesAndNullOptionalFields() throws SQLException {
        final SparePart7 sparePart = dao.searchSpareParts("test7 oil filter", 100, 0).getFirst();
        assertNull(sparePart.barcode());
        assertNull(sparePart.producer());
        assertNull(sparePart.description());
        assertTrue(sparePart.images().isEmpty());
    }

    @Test
    void searchSparePartsReturnsEmptyListWhenNothingMatches() throws SQLException {
        assertTrue(dao.searchSpareParts(UUID.randomUUID().toString(), 100, 0).isEmpty());
    }

    @Test
    void addNewPartStoresThePartWithImagesAndSetsItsId() throws SQLException {
        final byte[] front = {(byte) 0x89, 'P', 'N', 'G', 1};
        final byte[] back = {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF, 2};
        final ArrayList<SparePartImage7> images = new ArrayList<>(List.of(new SparePartImage7(0, "image/png", front),
                new SparePartImage7(1, "image/jpeg", back)));
        final SparePart7 part = new SparePart7("8930000000014", "Test7 new part", "cell",
                "ABC Auto Parts", new BigDecimal("100000.00"), "Test part", images);

        dao.addNewPart(part);

        assertTrue(part.id() > 0);

        final SparePart7 sparePart = dao.searchSpareParts("test7 new part", 100, 0).getFirst();
        assertEquals(part.id(), sparePart.id());
        assertEquals("8930000000014", sparePart.barcode());
        assertEquals(0, sparePart.stockQuantity());
        assertEquals(List.of(0, 1), sparePart.images().stream().map(SparePartImage7::ordinal).toList());

        final SparePartImageDAO7 imageDAO = new SparePartImageDAO7();
        assertArrayEquals(front, imageDAO.getImage(part.id(), 0).data());
        assertArrayEquals(back, imageDAO.getImage(part.id(), 1).data());
        assertEquals("image/jpeg", imageDAO.getImage(part.id(), 1).contentType());
    }

    @Test
    void addNewPartAcceptsMissingOptionalFields() throws SQLException {
        final SparePart7 part = new SparePart7(null, "Test7 minimal part", "piece", null,
                new BigDecimal("50000.00"), null, new ArrayList<>());

        dao.addNewPart(part);

        final SparePart7 sparePart = dao.searchSpareParts("test7 minimal part", 100, 0).getFirst();
        assertEquals(part.id(), sparePart.id());
        assertNull(sparePart.producer());
        assertTrue(sparePart.images().isEmpty());
    }

    @Test
    void addNewPartRejectsAnExistingBarcode() throws SQLException {
        final SparePart7 part = new SparePart7("8930000000007", "Test7 duplicate", "set", null, BigDecimal.TEN, null,
                new ArrayList<>(List.of(new SparePartImage7(0, "image/png", new byte[] {1}))));

        final SQLIntegrityConstraintViolationException error =
                assertThrows(SQLIntegrityConstraintViolationException.class, () -> dao.addNewPart(part));

        assertEquals("Barcode already exists", error.getMessage());
        assertEquals(-1, part.id());
        assertTrue(dao.searchSpareParts("test7 duplicate", 100, 0).isEmpty());
    }
}
