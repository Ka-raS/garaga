package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.util.Objects;

public final class Supplier7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private long id;
    private final String name;
    private final String address;
    private final String phoneNumber;
    private final String email;
    private final String description;

    public Supplier7(String name, String address, String phoneNumber, String email, String description) {
        this(-1, name, address, phoneNumber, email, description);
    }

    public Supplier7(long id, String name, String address, String phoneNumber, String email, String description) {
        this.id = id;
        this.name = Objects.requireNonNull(name, "name");
        this.address = Objects.requireNonNull(address, "address");
        this.phoneNumber = Objects.requireNonNull(phoneNumber, "phoneNumber");
        this.email = email;
        this.description = description;
    }

    public long id() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String name() {
        return name;
    }

    public String address() {
        return address;
    }

    public String phoneNumber() {
        return phoneNumber;
    }

    public String email() {
        return email;
    }

    public String description() {
        return description;
    }
}
