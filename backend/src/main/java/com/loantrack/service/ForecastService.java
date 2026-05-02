package com.loantrack.service;

import com.loantrack.dto.ForecastDtos.*;
import com.loantrack.entity.User;
import com.loantrack.repository.PaymentScheduleRepository;
import com.loantrack.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ForecastService {

    private final PaymentScheduleRepository scheduleRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public ForecastResponse getForecast(String userEmail, int months) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));

        LocalDate from = LocalDate.now();
        LocalDate to = from.plusMonths(months);

        var entries = scheduleRepository
                .findUpcomingByUserIdAndDateRange(user.getId(), from, to)
                .stream()
                .map(ps -> ForecastEntry.builder()
                        .dueDate(ps.getDueDate())
                        .loanNumber(ps.getLoan().getLoanNumber())
                        .loanType(ps.getLoan().getLoanType())
                        .amount(ps.getScheduledAmount())
                        .status(ps.getStatus())
                        .build())
                .collect(Collectors.toList());

        BigDecimal total = entries.stream()
                .map(ForecastEntry::getAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return ForecastResponse.builder()
                .entries(entries)
                .totalDue(total)
                .months(months)
                .from(from)
                .to(to)
                .build();
    }
}
