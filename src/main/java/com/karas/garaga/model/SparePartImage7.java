package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.util.Objects;

public final class SparePartImage7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final int ordinal;
    private final String contentType;
    private final byte[] data;

    public SparePartImage7(int ordinal, String contentType) {
        this.ordinal = ordinal;
        this.contentType = Objects.requireNonNull(contentType, "contentType");
        this.data = null;
    }

    public SparePartImage7(int ordinal, String contentType, byte[] data) {
        this.ordinal = ordinal;
        this.contentType = Objects.requireNonNull(contentType, "contentType");
        this.data = Objects.requireNonNull(data, "data");
    }

    public int ordinal() {
        return ordinal;
    }

    public String contentType() {
        return contentType;
    }

    public byte[] data() {
        return data;
    }
}
