package com.karas.garaga.dao;

import com.karas.garaga.model.SparePart7;
import com.karas.garaga.model.SparePartImage7;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.sql.Savepoint;
import java.util.ArrayList;

public final class SparePartDAO7 extends DAO7 {
    public SparePartDAO7() throws SQLException {
        super();
    }

    public ArrayList<SparePart7> searchSpareParts(String keyword, int limit, int offset) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("""
                SELECT p.id, p.barcode, p.name, p.unit, p.producer, p.unit_price, p.stock_quantity, p.description,
                       ARRAY(SELECT i.ordinal FROM tbl_spare_part_image7 i
                             WHERE i.spare_part7_id = p.id ORDER BY i.ordinal) AS image_ordinals,
                       ARRAY(SELECT i.content_type FROM tbl_spare_part_image7 i
                             WHERE i.spare_part7_id = p.id ORDER BY i.ordinal) AS image_content_types
                FROM tbl_spare_part7 p
                WHERE p.name ILIKE '%' || ? || '%'
                ORDER BY p.name, p.id
                LIMIT ? OFFSET ?
                """)) {
            ps.setString(1, keyword);
            ps.setInt(2, limit);
            ps.setInt(3, offset);

            try (ResultSet rs = ps.executeQuery()) {
                final ArrayList<SparePart7> spareParts = new ArrayList<>();
                while (rs.next()) {
                    final Integer[] ordinals = (Integer[]) rs.getArray("image_ordinals").getArray();
                    final String[] contentTypes = (String[]) rs.getArray("image_content_types").getArray();
                    final ArrayList<SparePartImage7> images = new ArrayList<>();
                    for (int i = 0; i < ordinals.length; i++) {
                        images.add(new SparePartImage7(ordinals[i], contentTypes[i]));
                    }

                    spareParts.add(new SparePart7(rs.getLong("id"), rs.getString("barcode"), rs.getString("name"),
                            rs.getString("unit"), rs.getString("producer"), rs.getBigDecimal("unit_price"),
                            rs.getInt("stock_quantity"), rs.getString("description"), images));
                }

                return spareParts;
            }
        }
    }

    public void addNewPart(SparePart7 part) throws SQLException {
        final boolean autoCommit = con.getAutoCommit();
        con.setAutoCommit(false);
        final Savepoint savepoint = con.setSavepoint();

        try (PreparedStatement ps = con.prepareStatement("""
                INSERT INTO tbl_spare_part7
                    (barcode, name, unit, producer, unit_price, stock_quantity, description)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (barcode) DO NOTHING
                RETURNING id
                """)) {
            ps.setString(1, part.barcode());
            ps.setString(2, part.name());
            ps.setString(3, part.unit());
            ps.setString(4, part.producer());
            ps.setBigDecimal(5, part.unitPrice());
            ps.setInt(6, part.stockQuantity());
            ps.setString(7, part.description());

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    throw new SQLIntegrityConstraintViolationException("Barcode already exists");
                }

                part.setId(rs.getLong("id"));
            }

            try (PreparedStatement psImage = con.prepareStatement("""
                    INSERT INTO tbl_spare_part_image7 (ordinal, content_type, data, spare_part7_id)
                    VALUES (?, ?, ?, ?)
                    """)) {
                for (final SparePartImage7 image : part.images()) {
                    psImage.setInt(1, image.ordinal());
                    psImage.setString(2, image.contentType());
                    psImage.setBytes(3, image.data());
                    psImage.setLong(4, part.id());
                    psImage.addBatch();
                }

                psImage.executeBatch();
            }

            if (autoCommit) {
                con.commit();
            }
        } catch (SQLException | RuntimeException e) {
            con.rollback(savepoint);
            throw e;
        } finally {
            con.setAutoCommit(autoCommit);
        }
    }
}
