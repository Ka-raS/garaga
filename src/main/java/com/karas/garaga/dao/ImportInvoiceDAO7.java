package com.karas.garaga.dao;

import com.karas.garaga.model.ImportInvoice7;
import com.karas.garaga.model.ImportPartDetail7;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Savepoint;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;

public final class ImportInvoiceDAO7 extends DAO7 {
    public ImportInvoiceDAO7() throws SQLException {
        super();
    }

    public void saveInvoice(ImportInvoice7 invoice) throws SQLException {
        if (invoice.importParts().isEmpty()) {
            throw new IllegalArgumentException("The invoice has no spare parts");
        }

        final boolean autoCommit = con.getAutoCommit();
        con.setAutoCommit(false);
        final Savepoint savepoint = con.setSavepoint();

        try (PreparedStatement ps = con.prepareStatement("""
                INSERT INTO tbl_import_invoice7 (imported_at, notes, supplier7_id, warehouse_staff7_id)
                VALUES (?, ?, ?, ?)
                RETURNING id
                """)) {
            ps.setObject(1, OffsetDateTime.ofInstant(invoice.importedAt(), ZoneOffset.UTC));
            ps.setString(2, invoice.notes());
            ps.setLong(3, invoice.supplier().id());
            ps.setLong(4, invoice.warehouseStaff().info().id());

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                invoice.setId(rs.getLong("id"));
            }

            try (PreparedStatement psDetail = con.prepareStatement("""
                    INSERT INTO tbl_import_part_detail7
                        (quantity, imported_unit_price, notes, import_invoice7_id, spare_part7_id)
                    VALUES (?, ?, ?, ?, ?)
                    """);
                 PreparedStatement psStock = con.prepareStatement("""
                    UPDATE tbl_spare_part7
                    SET stock_quantity = stock_quantity + ?
                    WHERE id = ?
                    """)) {
                for (final ImportPartDetail7 detail : invoice.importParts()) {
                    psDetail.setInt(1, detail.quantity());
                    psDetail.setBigDecimal(2, detail.importedUnitPrice());
                    psDetail.setString(3, detail.notes());
                    psDetail.setLong(4, invoice.id());
                    psDetail.setLong(5, detail.part().id());
                    psDetail.addBatch();

                    psStock.setInt(1, detail.quantity());
                    psStock.setLong(2, detail.part().id());
                    psStock.addBatch();
                }

                psDetail.executeBatch();
                psStock.executeBatch();
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
