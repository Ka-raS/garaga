package com.karas.garaga.dao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.karas.garaga.model.ImportInvoice7;
import com.karas.garaga.model.ImportPartDetail7;
import com.karas.garaga.model.SparePart7;
import com.karas.garaga.model.StaffInfo7;
import com.karas.garaga.model.Supplier7;
import com.karas.garaga.model.WarehouseStaff7;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class TestImportInvoiceDAO7 extends TestDAO7 {
    private ImportInvoiceDAO7 dao;
    private SparePartDAO7 sparePartDAO;
    private WarehouseStaff7 staff;
    private Supplier7 supplier;
    private SparePart7 oil;
    private SparePart7 brakePad;

    @BeforeEach
    void createDAO() throws SQLException {
        dao = new ImportInvoiceDAO7();
        sparePartDAO = new SparePartDAO7();

        try (Statement st = DAO7.con.createStatement();
             ResultSet rs = st.executeQuery("""
                     WITH member AS (
                         INSERT INTO tbl_member7 (username, password_hashed)
                         VALUES ('test7.warehouse', 'not used')
                         RETURNING id
                     )
                     INSERT INTO tbl_staff7 (fullname, phone_number, email, birth_date, position, member7_id)
                     SELECT 'Test7 Staff', '0000000721', 'staff@test7.vn', '1995-03-08', 'WAREHOUSE', id FROM member
                     RETURNING id, member7_id
                     """)) {
            rs.next();
            staff = new WarehouseStaff7(rs.getLong("member7_id"), "test7.warehouse", new StaffInfo7(rs.getLong("id"),
                    "Test7 Staff", "0000000721", "staff@test7.vn", LocalDate.of(1995, 3, 8)));
        }

        supplier = new Supplier7("Test7 Supplier", "Hà Nội", "0000000722", "supplier@test7.vn", null);
        new SupplierDAO7().addNewSupplier(supplier);

        oil = new SparePart7(null, "Test7 engine oil", "bottle", null, BigDecimal.ONE, null, new ArrayList<>());
        brakePad = new SparePart7(null, "Test7 brake pad", "set", null, BigDecimal.ONE, null, new ArrayList<>());
        sparePartDAO.addNewPart(oil);
        sparePartDAO.addNewPart(brakePad);
    }

    private int stockQuantity(SparePart7 part) throws SQLException {
        return sparePartDAO.searchSpareParts(part.name(), 100, 0).getFirst().stockQuantity();
    }

    private static long count(String sql, long id) throws SQLException {
        try (PreparedStatement ps = DAO7.con.prepareStatement(sql)) {
            ps.setLong(1, id);

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getLong(1);
            }
        }
    }

    @Test
    void saveInvoiceStoresDetailsIncreasesStockAndSetsId() throws SQLException {
        final ArrayList<ImportPartDetail7> parts = new ArrayList<>(List.of(
                new ImportPartDetail7(10, new BigDecimal("820000.00"), null, oil),
                new ImportPartDetail7(4, new BigDecimal("600000.50"), "Rush order", brakePad)));
        final ImportInvoice7 invoice = new ImportInvoice7(Instant.now(), "Paid in cash", parts, staff, supplier);

        dao.saveInvoice(invoice);

        assertTrue(invoice.id() > 0);
        assertEquals(new BigDecimal("10600002.00"), invoice.total());
        assertEquals(2, count("SELECT count(*) FROM tbl_import_part_detail7 WHERE import_invoice7_id = ?",
                invoice.id()));
        assertEquals(10, stockQuantity(oil));
        assertEquals(4, stockQuantity(brakePad));
    }

    @Test
    void saveInvoiceRejectsAnInvoiceWithoutParts() {
        final ImportInvoice7 invoice = new ImportInvoice7(Instant.now(), null, new ArrayList<>(), staff, supplier);

        assertThrows(IllegalArgumentException.class, () -> dao.saveInvoice(invoice));

        assertEquals(-1, invoice.id());
    }

    @Test
    void saveInvoiceRollsBackEverythingWhenAPartDoesNotExist() throws SQLException {
        final SparePart7 missing = new SparePart7(null, "Test7 missing part", "piece", null, BigDecimal.ONE, null,
                new ArrayList<>());
        final ArrayList<ImportPartDetail7> parts = new ArrayList<>(List.of(
                new ImportPartDetail7(5, BigDecimal.TEN, null, oil),
                new ImportPartDetail7(1, BigDecimal.TEN, null, missing)));
        final ImportInvoice7 invoice = new ImportInvoice7(Instant.now(), null, parts, staff, supplier);

        assertThrows(SQLException.class, () -> dao.saveInvoice(invoice));

        assertFalse(DAO7.con.getAutoCommit());
        assertEquals(0, count("SELECT count(*) FROM tbl_import_invoice7 WHERE supplier7_id = ?", supplier.id()));
        assertEquals(0, count("SELECT count(*) FROM tbl_import_part_detail7 WHERE spare_part7_id = ?", oil.id()));
        assertEquals(0, stockQuantity(oil));
    }
}
