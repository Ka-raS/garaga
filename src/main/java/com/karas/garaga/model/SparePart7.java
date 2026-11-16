package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Objects;

public final class SparePart7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private long id;
    private final String barcode;
    private final String name;
    private final String unit;
    private final String producer;
    private final BigDecimal unitPrice;
    private final int stockQuantity;
    private final String description;
    private final ArrayList<SparePartImage7> images;

    public SparePart7(String barcode, String name, String unit, String producer, BigDecimal unitPrice,
                      String description, ArrayList<SparePartImage7> images) {
        this(-1, barcode, name, unit, producer, unitPrice, 0, description, images);
    }

    public SparePart7(long id, String barcode, String name, String unit, String producer, BigDecimal unitPrice,
                      int stockQuantity, String description, ArrayList<SparePartImage7> images) {
        this.id = id;
        this.barcode = barcode;
        this.name = Objects.requireNonNull(name, "name");
        this.unit = Objects.requireNonNull(unit, "unit");
        this.producer = producer;
        this.unitPrice = Objects.requireNonNull(unitPrice, "unitPrice");
        this.stockQuantity = stockQuantity;
        this.description = description;
        this.images = Objects.requireNonNull(images, "images");
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String barcode() {
        return barcode;
    }

    public String name() {
        return name;
    }

    public String unit() {
        return unit;
    }

    public String producer() {
        return producer;
    }

    public BigDecimal unitPrice() {
        return unitPrice;
    }

    public int stockQuantity() {
        return stockQuantity;
    }

    public String description() {
        return description;
    }

    public ArrayList<SparePartImage7> images() {
        return images;
    }
}
