package com.karas.garaga.dao;

import java.sql.Connection;
import java.sql.SQLException;
import org.flywaydb.core.Flyway;

public class DAO7 {
    protected static Connection con;

    public DAO7() throws SQLException {
        synchronized (DAO7.class) {
            if (con == null || !con.isValid(2)) {
                final Flyway flyway = Flyway.configure().envVars().connectRetries(10).load();
                if (con == null) {
                    flyway.migrate();
                }

                con = flyway.getConfiguration().getDataSource().getConnection();
            }
        }
    }
}
