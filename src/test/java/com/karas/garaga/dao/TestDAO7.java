package com.karas.garaga.dao;

import java.sql.SQLException;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;

abstract class TestDAO7 {
    @BeforeEach
    void beginTransaction() throws SQLException {
        new DAO7();
        DAO7.con.setAutoCommit(false);
    }

    @AfterEach
    void rollbackTransaction() throws SQLException {
        DAO7.con.rollback();
        DAO7.con.setAutoCommit(true);
    }
}
