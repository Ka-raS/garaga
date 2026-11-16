package com.karas.garaga.dao;

import com.karas.garaga.model.Supplier7;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;

public final class SupplierDAO7 extends DAO7 {
    public SupplierDAO7() throws SQLException {
        super();
    }

    public ArrayList<Supplier7> searchSuppliers(String keyword, int limit, int offset) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("""
                SELECT id, name, address, phone_number, email, description
                FROM tbl_supplier7
                WHERE name ILIKE '%' || ? || '%'
                ORDER BY name, id
                LIMIT ? OFFSET ?
                """)) {
            ps.setString(1, keyword);
            ps.setInt(2, limit);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                final ArrayList<Supplier7> suppliers = new ArrayList<>();
                while (rs.next()) {
                    suppliers.add(new Supplier7(rs.getLong("id"), rs.getString("name"), rs.getString("address"),
                            rs.getString("phone_number"), rs.getString("email"), rs.getString("description")));
                }

                return suppliers;
            }
        }
    }

    public void addNewSupplier(Supplier7 supplier) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("""
                INSERT INTO tbl_supplier7 (name, address, phone_number, email, description)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT (phone_number) DO NOTHING
                RETURNING id
                """)) {
            ps.setString(1, supplier.name());
            ps.setString(2, supplier.address());
            ps.setString(3, supplier.phoneNumber());
            ps.setString(4, supplier.email());
            ps.setString(5, supplier.description());

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLIntegrityConstraintViolationException("Phone number already exists");
                }

                supplier.setId(rs.getLong("id"));
            }
        }
    }
}
