package com.loantrack.controller;

import com.loantrack.dto.ForecastDtos.*;
import com.loantrack.service.ForecastService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/forecast")
@RequiredArgsConstructor
@Tag(name = "Forecast", description = "Payment forecasting endpoints")
@SecurityRequirement(name = "bearerAuth")
public class ForecastController {

    private final ForecastService forecastService;

    @GetMapping
    @Operation(summary = "Get payment forecast for the next N months across all loans")
    public ResponseEntity<ForecastResponse> getForecast(
            @AuthenticationPrincipal UserDetails user,
            @RequestParam(defaultValue = "6") int months) {
        return ResponseEntity.ok(forecastService.getForecast(user.getUsername(), months));
    }
}
