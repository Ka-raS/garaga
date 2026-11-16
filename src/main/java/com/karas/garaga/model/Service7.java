package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Duration;
import java.util.Objects;

public final class Service7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final long id;
    private final String name;
    private final BigDecimal price;
    private final Duration duration;
    private final String description;
    private final boolean available;

    public Service7(long id, String name, BigDecimal price, Duration duration, String description, boolean available) {
        this.id = id;
        this.name = Objects.requireNonNull(name, "name");
        this.price = Objects.requireNonNull(price, "price");
        this.duration = duration;
        this.description = description;
        this.available = available;
    }

    public long id() {
        return id;
    }

    public String name() {
        return name;
    }

    public BigDecimal price() {
        return price;
    }

    public Duration duration() {
        return duration;
    }

    public String description() {
        return description;
    }

    public boolean available() {
        return available;
    }
}
