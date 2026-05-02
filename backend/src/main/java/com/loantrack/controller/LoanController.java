package com.loantrack.controller;

import com.loantrack.dto.LoanDtos.*;
import com.loantrack.service.LoanService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/loans")
@RequiredArgsConstructor
@Tag(name = "Loans", description = "Loan management endpoints")
@SecurityRequirement(name = "bearerAuth")
public class LoanController {

    private final LoanService loanService;

    @PostMapping
    @Operation(summary = "Create a new loan and generate amortization schedule")
    public ResponseEntity<LoanResponse> createLoan(
            @AuthenticationPrincipal UserDetails user,
            @Valid @RequestBody CreateLoanRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(loanService.createLoan(user.getUsername(), request));
    }

    @GetMapping
    @Operation(summary = "Get all loans for the authenticated user")
    public ResponseEntity<List<LoanSummary>> getMyLoans(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(loanService.getUserLoans(user.getUsername()));
    }

    @GetMapping("/{loanId}")
    @Operation(summary = "Get loan details by ID")
    public ResponseEntity<LoanResponse> getLoan(
            @AuthenticationPrincipal UserDetails user,
            @PathVariable Long loanId) {
        return ResponseEntity.ok(loanService.getLoanById(user.getUsername(), loanId));
    }
}
