package com.karas.garaga.model;

import java.io.Serial;
import java.io.Serializable;
import java.util.Objects;

public class Member7 implements Serializable {
    @Serial
    private static final long serialVersionUID = 2026_11_02_001L;

    private final long id;
    private final String username;
    private final String password;

    public Member7(String username, String password) {
        this.id = -1;
        this.username = Objects.requireNonNull(username, "username");
        this.password = Objects.requireNonNull(password, "password");
    }

    public Member7(long id, String username) {
        this.id = id;
        this.username = Objects.requireNonNull(username, "username");
        this.password = null;
    }

    public long id() {
        return id;
    }

    public String username() {
        return username;
    }

    public String password() {
        return password;
    }
}
