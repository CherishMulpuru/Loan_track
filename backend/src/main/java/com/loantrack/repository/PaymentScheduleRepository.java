package com.loantrack.repository;

import com.loantrack.entity.PaymentSchedule;
import com.loantrack.entity.PaymentSchedule.ScheduleStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface PaymentScheduleRepository extends JpaRepository<PaymentSchedule, Long> {

    List<PaymentSchedule> findByLoanIdOrderByPaymentNumber(Long loanId);

    List<PaymentSchedule> findByLoanIdAndStatus(Long loanId, ScheduleStatus status);

    @Query("SELECT ps FROM PaymentSchedule ps WHERE ps.loan.user.id = :userId " +
           "AND ps.dueDate BETWEEN :from AND :to ORDER BY ps.dueDate")
    List<PaymentSchedule> findUpcomingByUserIdAndDateRange(
            @Param("userId") Long userId,
            @Param("from") LocalDate from,
            @Param("to") LocalDate to);

    @Query("SELECT ps FROM PaymentSchedule ps WHERE ps.loan.id = :loanId " +
           "AND ps.status = 'PENDING' ORDER BY ps.dueDate")
    List<PaymentSchedule> findPendingByLoanId(@Param("loanId") Long loanId);
}
