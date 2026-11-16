package com.karas.garaga.dao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.karas.garaga.model.Supplier7;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class TestSupplierDAO7 extends TestDAO7 {
    private SupplierDAO7 dao;
    private long anPhatId;
    private long vietAutoId;

    @BeforeEach
    void createDAO() throws SQLException {
        dao = new SupplierDAO7();

        try (Statement st = DAO7.con.createStatement()) {
            try (ResultSet rs = st.executeQuery("""
                    INSERT INTO tbl_supplier7 (name, address, phone_number, email, description)
                    VALUES ('Test7 An Phat Lubricants', '45 Nguyễn Trãi, Thanh Xuân, Hà Nội', '0000000701',
                            'order@anphat.test7.vn', NULL)
                    RETURNING id
                    """)) {
                rs.next();
                anPhatId = rs.getLong("id");
            }

            try (ResultSet rs = st.executeQuery("""
                    INSERT INTO tbl_supplier7 (name, address, phone_number, email, description)
                    VALUES ('Viet Auto Parts Test7', '12 Trần Duy Hưng, Cầu Giấy, Hà Nội', '0000000702',
                            'sales@vietauto.test7.vn', 'Genuine Toyota parts')
                    RETURNING id
                    """)) {
                rs.next();
                vietAutoId = rs.getLong("id");
            }
        }
    }

    @Test
    void searchSuppliersReturnsAllFieldsIgnoringCase() throws SQLException {
        final ArrayList<Supplier7> suppliers = dao.searchSuppliers("TEST7 AN PHAT", 100, 0);
        assertEquals(1, suppliers.size());

        final Supplier7 supplier = suppliers.getFirst();
        assertEquals(anPhatId, supplier.id());
        assertEquals("Test7 An Phat Lubricants", supplier.name());
        assertEquals("45 Nguyễn Trãi, Thanh Xuân, Hà Nội", supplier.address());
        assertEquals("0000000701", supplier.phoneNumber());
        assertEquals("order@anphat.test7.vn", supplier.email());
        assertNull(supplier.description());
    }

    @Test
    void searchSuppliersWithEmptyKeywordReturnsAllSuppliers() throws SQLException {
        assertTrue(dao.searchSuppliers("", Integer.MAX_VALUE, 0).stream().map(Supplier7::id).toList()
                .containsAll(List.of(anPhatId, vietAutoId)));
    }

    @Test
    void searchSuppliersReturnsTheRequestedPage() throws SQLException {
        assertEquals(List.of(anPhatId), dao.searchSuppliers("test7", 1, 0).stream().map(Supplier7::id).toList());
        assertEquals(List.of(vietAutoId), dao.searchSuppliers("test7", 1, 1).stream().map(Supplier7::id).toList());
        assertTrue(dao.searchSuppliers("test7", 1, 2).isEmpty());
    }

    @Test
    void searchSuppliersReturnsEmptyListWhenNothingMatches() throws SQLException {
        assertTrue(dao.searchSuppliers(UUID.randomUUID().toString(), 100, 0).isEmpty());
    }

    @Test
    void addNewSupplierStoresTheSupplierAndSetsItsId() throws SQLException {
        final Supplier7 supplier = new Supplier7("Test7 new supplier", "Hà Đông", "0000000703", "new@test7.vn", null);

        dao.addNewSupplier(supplier);

        assertTrue(supplier.id() > 0);

        final ArrayList<Supplier7> found = dao.searchSuppliers("test7 new supplier", 100, 0);
        assertEquals(1, found.size());
        assertEquals(supplier.id(), found.getFirst().id());
        assertEquals("0000000703", found.getFirst().phoneNumber());
    }

    @Test
    void addNewSupplierRejectsAnExistingPhoneNumber() throws SQLException {
        final Supplier7 supplier = new Supplier7("Test7 duplicate", "Thanh Xuân", "0000000701", "dup@test7.vn", null);

        final SQLIntegrityConstraintViolationException error =
                assertThrows(SQLIntegrityConstraintViolationException.class, () -> dao.addNewSupplier(supplier));

        assertEquals("Phone number already exists", error.getMessage());
        assertEquals(-1, supplier.id());
        assertTrue(dao.searchSuppliers("test7 duplicate", 100, 0).isEmpty());
    }
}
