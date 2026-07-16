package com.openclassrooms.yourwayapi;

public final class ApiEndpoints {
    private ApiEndpoints() {
    }

    public static final String AUTH_BASE = "/api/auth";
    public static final String AUTH_REGISTER = AUTH_BASE + "/register";
    public static final String AUTH_LOGIN = AUTH_BASE + "/login";
    public static final String AUTH_REFRESH = AUTH_BASE + "/refresh";
    public static final String AUTH_LOGOUT = AUTH_BASE + "/logout";
    public static final String AUTH_CSRF = AUTH_BASE + "/csrf";
    public static final String AUTH_ME = AUTH_BASE + "/me";

    public static final String ENV = "/api/env";
    public static final String CHATS = "/api/chats";
    public static final String CHATS_AGENT_VIEW = CHATS + "/agent-view";
    public static final String USERS = "/api/users";

}
