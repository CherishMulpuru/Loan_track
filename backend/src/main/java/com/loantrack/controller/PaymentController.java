package com.loantrack.controller;

import com.loantrack.dto.PaymentDtos.*;
import com.loantrack.service.PaymentService;
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
@RequestMapping("/api/v1/loans/{loanId}")
@RequiredArgsConstructor
@Tag(name = "Payments", description = "Payment and amortization schedule endpoints")
@SecurityRequirement(name = "bearerAuth")
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/payments")
    @Operation(summary = "Make a payment on a loan")
    public ResponseEntity<PaymentResponse> makePayment(
            @AuthenticationPrincipal UserDetails user,
            @PathVariable Long loanId,
            @Valid @RequestBody MakePaymentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(paymentService.makePayment(user.getUsername(), loanId, request));
    }

    @GetMapping("/payments")
    @Operation(summary = "Get payment history for a loan")
    public ResponseEntity<List<PaymentResponse>> getPaymentHistory(
            @AuthenticationPrincipal UserDetails user,
            @PathVariable Long loanId) {
        return ResponseEntity.ok(paymentService.getPaymentHistory(user.getUsername(), loanId));
    }

    @GetMapping("/schedule")
    @Operation(summary = "Get full amortization schedule for a loan")
    public ResponseEntity<List<ScheduleEntryResponse>> getSchedule(
            @AuthenticationPrincipal UserDetails user,
            @PathVariable Long loanId) {
        return ResponseEntity.ok(paymentService.getAmortizationSchedule(user.getUsername(), loanId));
    }
}
