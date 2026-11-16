package com.karas.garaga.dao;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.karas.garaga.model.Service7;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class TestServiceDAO7 extends TestDAO7 {
    private ServiceDAO7 dao;
    private long maintenanceId;

    @BeforeEach
    void createDAO() throws SQLException {
        dao = new ServiceDAO7();

        try (Statement st = DAO7.con.createStatement()) {
            st.executeUpdate("""
                    INSERT INTO tbl_service7 (name, price, duration_minutes, description, available) VALUES
                        ('Test7 brake pad replacement', 400000, 60, NULL, true),
                        ('Test7 battery replacement', 100000, NULL, NULL, true),
                        ('Test7 ceramic coating', 6000000, 480, NULL, false)
                    """);

            try (ResultSet rs = st.executeQuery("""
                    INSERT INTO tbl_service7 (name, price, duration_minutes, description, available)
                    VALUES ('Test7 periodic maintenance', 1200000, 120, 'Oil change and safety check', true)
                    RETURNING id
                    """)) {
                rs.next();
                maintenanceId = rs.getLong("id");
            }
        }
    }

    @Test
    void searchServicesReturnsAllFieldsOfTheMatchingService() throws SQLException {
        final ArrayList<Service7> services = dao.searchServices("test7 periodic", 100, 0);
        assertEquals(1, services.size());

        final Service7 service = services.getFirst();
        assertEquals(maintenanceId, service.id());
        assertEquals("Test7 periodic maintenance", service.name());
        assertEquals(new BigDecimal("1200000.00"), service.price());
        assertEquals(Duration.ofHours(2), service.duration());
        assertEquals("Oil change and safety check", service.description());
        assertTrue(service.available());
    }

    @Test
    void searchServicesIgnoresCaseSortsByNameAndSkipsUnavailableServices() throws SQLException {
        assertEquals(List.of("Test7 battery replacement", "Test7 brake pad replacement", "Test7 periodic maintenance"),
                dao.searchServices("TEST7", 100, 0).stream().map(Service7::name).toList());
    }

    @Test
    void searchServicesReturnsTheRequestedPage() throws SQLException {
        assertEquals(List.of("Test7 brake pad replacement"),
                dao.searchServices("test7", 1, 1).stream().map(Service7::name).toList());
        assertTrue(dao.searchServices("test7", 1, 3).isEmpty());
    }

    @Test
    void searchServicesReturnsNullDurationWhenItIsUnknown() throws SQLException {
        assertNull(dao.searchServices("test7 battery", 100, 0).getFirst().duration());
    }

    @Test
    void searchServicesSkipsUnavailableServices() throws SQLException {
        assertTrue(dao.searchServices("test7 ceramic", 100, 0).isEmpty());
    }

    @Test
    void searchServicesReturnsEmptyListWhenNothingMatches() throws SQLException {
        assertTrue(dao.searchServices(UUID.randomUUID().toString(), 100, 0).isEmpty());
    }
}
