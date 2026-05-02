package com.loantrack.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.loantrack.dto.AuthDtos.*;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
@DisplayName("AuthController Integration Tests")
class AuthControllerIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    @Test
    @DisplayName("POST /api/v1/auth/register - creates user and returns JWT")
    void register_success() throws Exception {
        RegisterRequest req = RegisterRequest.builder()
                .email("cherish@loantrack.io")
                .password("securePass123")
                .firstName("Cherish")
                .lastName("Mulpuru")
                .build();

        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.token", notNullValue()))
                .andExpect(jsonPath("$.tokenType", is("Bearer")))
                .andExpect(jsonPath("$.email", is("cherish@loantrack.io")));
    }

    @Test
    @DisplayName("POST /api/v1/auth/register - duplicate email returns 400")
    void register_duplicateEmail() throws Exception {
        RegisterRequest req = RegisterRequest.builder()
                .email("dup@loantrack.io")
                .password("securePass123")
                .firstName("Test")
                .lastName("User")
                .build();

        // First registration
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());

        // Duplicate
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest());
    }

    @Test
    @DisplayName("POST /api/v1/auth/login - valid credentials return JWT")
    void login_success() throws Exception {
        // Register first
        RegisterRequest reg = RegisterRequest.builder()
                .email("login@loantrack.io")
                .password("securePass123")
                .firstName("Test")
                .lastName("User")
                .build();
        mockMvc.perform(post("/api/v1/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(reg)));

        // Login
        LoginRequest login = LoginRequest.builder()
                .email("login@loantrack.io")
                .password("securePass123")
                .build();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token", notNullValue()));
    }

    @Test
    @DisplayName("POST /api/v1/auth/login - wrong password returns 401")
    void login_wrongPassword() throws Exception {
        LoginRequest login = LoginRequest.builder()
                .email("nobody@loantrack.io")
                .password("wrong")
                .build();

        mockMvc.perform(post("/api/v1/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(login)))
                .andExpect(status().isUnauthorized());
    }
}
